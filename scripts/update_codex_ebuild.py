#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Codex Ebuild CRATES Updater
Automates the process of extracting the Rust CRATES list from a source tarball 
using pycargoebuild and updating the local codex ebuild.
Integrates with Portage's DISTDIR to avoid duplicate downloads, uses /var/tmp 
as the temporary directory, and only cleans it up on success to allow resuming.
Handles missing digests by generating the manifest first, and copies crates 
from Cargo cache to DISTDIR to leverage ~/.cargo/config.toml registry mirrors.
Includes self-healing for corrupted or mismatched files.
Appends the output of update_packages.py to README.md at the end.
"""

import os
import sys
import re
import urllib.request
import shutil
import subprocess

REPO_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_EBUILD_DIR = os.path.join(REPO_DIR, "dev-util", "codex")

def find_ebuild(ebuild_path=None):
    """Finds the path to the codex ebuild file."""
    if ebuild_path:
        if os.path.exists(ebuild_path):
            return os.path.abspath(ebuild_path)
        else:
            print(f"Error: Specified ebuild file not found: {ebuild_path}")
            sys.exit(1)
            
    if not os.path.isdir(DEFAULT_EBUILD_DIR):
        print(f"Error: Default codex directory not found: {DEFAULT_EBUILD_DIR}")
        sys.exit(1)
        
    ebuilds = [f for f in os.listdir(DEFAULT_EBUILD_DIR) if f.startswith("codex-") and f.endswith(".ebuild")]
    if not ebuilds:
        print(f"Error: No codex ebuild files found in {DEFAULT_EBUILD_DIR}")
        sys.exit(1)
        
    # Sort and pick the latest ebuild
    ebuilds.sort()
    latest_ebuild = ebuilds[-1]
    return os.path.join(DEFAULT_EBUILD_DIR, latest_ebuild)

def extract_version(ebuild_path):
    """Extracts the package version (PV) from the ebuild filename."""
    filename = os.path.basename(ebuild_path)
    match = re.match(r'^codex-(.+)\.ebuild$', filename)
    if not match:
        print(f"Error: Could not parse version from ebuild filename: {filename}")
        sys.exit(1)
    return match.group(1)

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Update Codex ebuild CRATES using pycargoebuild.")
    parser.add_argument("--ebuild", help="Path to the codex ebuild file (optional).")
    args = parser.parse_args()
    
    ebuild_path = find_ebuild(args.ebuild)
    pv = extract_version(ebuild_path)
    print(f"Target ebuild: {ebuild_path}")
    print(f"Parsed version (PV): {pv}")
    
    # 1. Query DISTDIR from portageq
    try:
        distdir = subprocess.run(["portageq", "envvar", "DISTDIR"], capture_output=True, text=True, check=True).stdout.strip()
    except Exception as e:
        print(f"Warning: Could not query portageq for DISTDIR: {e}. Falling back to /var/cache/distfiles")
        distdir = "/var/cache/distfiles"
        
    tar_filename = f"codex-{pv}.tar.gz"
    tar_path = os.path.join(distdir, tar_filename)
    tar_url = f"https://github.com/openai/codex/archive/refs/tags/rust-v{pv}.tar.gz"
    print(f"Portage DISTDIR is: {distdir}")
    print(f"Expected source tarball path: {tar_path}")
    
    # 2. Check if the tarball exists in DISTDIR; if not, run ebuild manifest to download
    if not os.path.exists(tar_path):
        print(f"Tarball {tar_filename} not found in DISTDIR. Attempting to download via ebuild manifest...")
        try:
            # Running manifest downloads all files in SRC_URI (including the source tarball)
            subprocess.run(["ebuild", os.path.basename(ebuild_path), "manifest"], 
                           cwd=os.path.dirname(ebuild_path), check=True)
            print("Ebuild manifest completed, tarball downloaded.")
        except subprocess.CalledProcessError as e:
            print(f"Warning: ebuild manifest failed (possibly due to outdated/missing crate digests): {e}")
            print(f"Falling back to direct download of {tar_url} to {tar_path}...")
            try:
                # Direct download into DISTDIR using urllib
                headers = {'User-Agent': 'Mozilla/5.0 (Gentoo Linux; Antigravity Updater)'}
                req = urllib.request.Request(tar_url, headers=headers)
                with urllib.request.urlopen(req) as response, open(tar_path, 'wb') as out_file:
                    shutil.copyfileobj(response, out_file)
                print("Direct download completed.")
                
                # Regenerate initial manifest for the downloaded file
                print("Generating initial manifest...")
                subprocess.run(["ebuild", os.path.basename(ebuild_path), "manifest"], 
                               cwd=os.path.dirname(ebuild_path), check=True)
            except Exception as ex:
                print(f"Error: Direct download/manifest generation failed: {ex}")
                sys.exit(1)
    else:
        print(f"Found existing tarball in DISTDIR: {tar_path}")
        
    # 3. Use temporary directory under /var/tmp
    temp_dir = f"/var/tmp/codex-{pv}-tmp"
    print(f"Temporary extraction directory: {temp_dir}")
    
    # Check if we can reuse the already extracted directory (to resume on retry)
    codex_rs_path = None
    if os.path.exists(temp_dir):
        for root, dirs, files in os.walk(temp_dir):
            if "codex-rs" in dirs:
                codex_rs_path = os.path.join(root, "codex-rs")
                break
                
    if codex_rs_path:
        print(f"Found existing extracted source at: {codex_rs_path}")
        print("Skipping extraction step.")
    else:
        # Clean incomplete directory if any
        if os.path.exists(temp_dir):
            shutil.rmtree(temp_dir)
        os.makedirs(temp_dir, exist_ok=True)
        
        # Extract the tarball
        print(f"Extracting tarball to: {temp_dir}...")
        try:
            shutil.unpack_archive(tar_path, temp_dir)
            print("Extraction completed.")
        except Exception as e:
            print(f"Error extracting tarball: {e}")
            sys.exit(1)
            
        # Locate codex-rs directory after extraction
        for root, dirs, files in os.walk(temp_dir):
            if "codex-rs" in dirs:
                codex_rs_path = os.path.join(root, "codex-rs")
                break
                
    if not codex_rs_path:
        print("Error: Could not find 'codex-rs' directory in the extracted files.")
        sys.exit(1)
        
    print(f"Found 'codex-rs' at: {codex_rs_path}")
    
    # Determine the original user's CARGO_HOME to use their config.toml
    cargo_home = os.environ.get("CARGO_HOME")
    if not cargo_home:
        sudo_user = os.environ.get("SUDO_USER")
        if sudo_user:
            try:
                import pwd
                user_home = pwd.getpwnam(sudo_user).pw_dir
                cargo_home = os.path.join(user_home, ".cargo")
            except Exception:
                pass
    if not cargo_home:
        cargo_home = os.path.expanduser("~/.cargo")
        
    cargo_env = os.environ.copy()
    cargo_env["CARGO_HOME"] = cargo_home
    print(f"Using CARGO_HOME: {cargo_home}")
    
    # 4. Pre-fetch crates using cargo (which uses ~/.cargo/config.toml mirrors)
    print("Running 'cargo fetch' to download dependencies (respects ~/.cargo/config.toml)...")
    try:
        subprocess.run(["cargo", "fetch"], cwd=codex_rs_path, env=cargo_env, check=True)
        print("Cargo fetch completed successfully.")
    except Exception as e:
        print(f"Warning: Cargo fetch failed: {e}. Attempting to proceed anyway...")
        
    # 5. Copy cached `.crate` files from CARGO_HOME registry cache to Portage DISTDIR
    cache_dir = os.path.join(cargo_home, "registry", "cache")
    crates_copied = 0
    if os.path.isdir(cache_dir):
        print(f"Scanning Cargo cache in {cache_dir} for downloaded crates...")
        for root, dirs, files in os.walk(cache_dir):
            for file in files:
                if file.endswith(".crate"):
                    src_file = os.path.join(root, file)
                    dest_file = os.path.join(distdir, file)
                    
                    need_copy = False
                    if not os.path.exists(dest_file):
                        need_copy = True
                    else:
                        # Check size to identify 0-byte or corrupted downloads
                        src_size = os.path.getsize(src_file)
                        dest_size = os.path.getsize(dest_file)
                        if dest_size == 0 or dest_size != src_size:
                            print(f"Crate {file} in DISTDIR is empty or size differs ({dest_size} vs {src_size} bytes). Replacing...")
                            try:
                                os.remove(dest_file)
                                need_copy = True
                            except Exception as ex:
                                print(f"Warning: Failed to remove corrupted file {dest_file}: {ex}")
                                
                    if need_copy:
                        try:
                            shutil.copy2(src_file, dest_file)
                            crates_copied += 1
                        except Exception as e:
                            print(f"Warning: Failed to copy {file} to DISTDIR: {e}")
        print(f"Copied {crates_copied} new crate(s) to Portage DISTDIR ({distdir}).")
    else:
        print(f"Warning: Cargo cache directory not found: {cache_dir}")
        
    # 6. Run pycargoebuild in codex-rs on member cli
    print("Running pycargoebuild ./cli in codex-rs...")
    try:
        res = subprocess.run(["pycargoebuild", "-f", "./cli"], cwd=codex_rs_path, env=cargo_env, 
                             capture_output=True, text=True, check=True)
        print(res.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running pycargoebuild (exit code {e.returncode}):")
        print(e.stdout)
        print(e.stderr)
        
        # Self-healing: Check for checksum mismatch in output
        mismatch_match = re.search(r"Checksum mismatch for '([^']+)'", e.stderr)
        if not mismatch_match:
            mismatch_match = re.search(r"Checksum mismatch for '([^']+)'", e.stdout)
            
        if mismatch_match:
            corrupted_file = mismatch_match.group(1)
            print(f"\n[Self-Healing] Detected corrupted file in DISTDIR: {corrupted_file}")
            if os.path.exists(corrupted_file):
                try:
                    os.remove(corrupted_file)
                    print(f"[Self-Healing] Successfully deleted corrupted file: {corrupted_file}")
                    print("[Self-Healing] Please run this script again to replace it with a fresh version.")
                except Exception as ex:
                    print(f"Error deleting corrupted file: {ex}")
        sys.exit(1)
        
    # Find the generated ebuild file
    generated_ebuilds = [f for f in os.listdir(codex_rs_path) if f.startswith("codex-cli-") and f.endswith(".ebuild")]
    if not generated_ebuilds:
        print("Error: pycargoebuild did not generate any ebuild file.")
        sys.exit(1)
        
    gen_ebuild_path = os.path.join(codex_rs_path, generated_ebuilds[0])
    print(f"Generated ebuild file: {gen_ebuild_path}")
    
    # Read the generated ebuild content
    with open(gen_ebuild_path, "r", encoding="utf-8") as f:
        gen_content = f.read()
        
    # Extract CRATES block
    crates_match = re.search(r'CRATES="[^"]*"', gen_content)
    if not crates_match:
        print("Error: Could not find CRATES block in the generated ebuild file.")
        sys.exit(1)
        
    new_crates_block = crates_match.group(0)
    
    # Extract GIT_CRATES block (if any)
    git_crates_match = re.search(r'declare -A GIT_CRATES=\([\s\S]*?\)', gen_content)
    
    # Read target ebuild content
    with open(ebuild_path, "r", encoding="utf-8") as f:
        target_content = f.read()
        
    # Find the old CRATES block in the target ebuild to replace
    target_crates_match = re.search(r'CRATES="[^"]*"', target_content)
    if not target_crates_match:
        print("Error: Could not find CRATES block in the target ebuild file.")
        sys.exit(1)
        
    old_crates_block = target_crates_match.group(0)
    
    # Replace the old CRATES block with the new one
    updated_content = target_content.replace(old_crates_block, new_crates_block)
    
    # Replace the GIT_CRATES block
    target_git_crates_match = re.search(r'declare -A GIT_CRATES=\([\s\S]*?\)', target_content)
    if git_crates_match:
        new_git_crates_block = git_crates_match.group(0)
        if target_git_crates_match:
            old_git_crates_block = target_git_crates_match.group(0)
            updated_content = updated_content.replace(old_git_crates_block, new_git_crates_block)
            print(f"Successfully updated GIT_CRATES in {ebuild_path}")
        else:
            updated_content = updated_content.replace(new_crates_block, new_crates_block + "\n\n" + new_git_crates_block)
            print(f"Successfully added GIT_CRATES to {ebuild_path}")
    elif target_git_crates_match:
        old_git_crates_block = target_git_crates_match.group(0)
        updated_content = updated_content.replace(old_git_crates_block, "")
        print(f"Successfully removed GIT_CRATES from {ebuild_path}")
        
    # Update RUSTY_V8_TAG automatically based on the v8 crate version
    v8_match = re.search(r'\bv8@([0-9.]+)\b', new_crates_block)
    if v8_match:
        new_v8_tag = v8_match.group(1)
        target_v8_tag_match = re.search(r'RUSTY_V8_TAG="[^"]*"', target_content)
        if target_v8_tag_match:
            old_v8_tag_block = target_v8_tag_match.group(0)
            new_v8_tag_block = f'RUSTY_V8_TAG="{new_v8_tag}"'
            updated_content = updated_content.replace(old_v8_tag_block, new_v8_tag_block)
            print(f"Successfully updated RUSTY_V8_TAG to {new_v8_tag} in {ebuild_path}")
            
    # Write updated content back to target ebuild
    with open(ebuild_path, "w", encoding="utf-8") as f:
        f.write(updated_content)
    print(f"Successfully updated CRATES and GIT_CRATES in {ebuild_path}")
    
    # Regenerate final Manifest
    print("Regenerating final Manifest...")
    try:
        subprocess.run(["ebuild", os.path.basename(ebuild_path), "manifest"], 
                       cwd=os.path.dirname(ebuild_path), check=True)
        print("Manifest regenerated successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Warning: Manifest generation failed: {e}")
        # Do not clean up on failure
        sys.exit(1)
        
    # Run update_packages.py to get the package update summary
    print("Running scripts/update_packages.py to get the final update summary...")
    try:
        res = subprocess.run([sys.executable, os.path.join(REPO_DIR, "scripts", "update_packages.py")],
                             capture_output=True, text=True, check=True)
        update_summary = res.stdout
    except subprocess.CalledProcessError as e:
        print(f"Warning: Failed to run update_packages.py: {e}")
        update_summary = f"Error running update_packages.py:\n{e.stderr}\n{e.stdout}"

    # Output the update_packages.py summary results to README.md
    readme_path = os.path.join(REPO_DIR, "README.md")
    print(f"Appending update summary to {readme_path}...")
    try:
        with open(readme_path, "a", encoding="utf-8") as f:
            f.write(f"\n## Package Update Summary\n")
            f.write("```text\n")
            f.write(update_summary)
            f.write("```\n")
        print("README.md updated.")
    except Exception as e:
        print(f"Error writing to README.md: {e}")
        sys.exit(1)
        
    # Clean up only on success
    if os.path.exists(temp_dir):
        print(f"Cleaning up temporary directory: {temp_dir}")
        shutil.rmtree(temp_dir)

if __name__ == "__main__":
    main()
