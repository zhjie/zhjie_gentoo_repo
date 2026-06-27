#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Go Ebuild Version Updater (Simple Mode)
Copies the ebuild for new versions, updates the git commit hash (for chezmoi),
and runs ebuild manifest to download the dependencies from remote servers.
"""

import os
import sys
import re
import subprocess

REPO_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def find_latest_ebuild(category, name):
    pkg_dir = os.path.join(REPO_DIR, category, name)
    if not os.path.isdir(pkg_dir):
        print(f"Error: Package directory not found: {pkg_dir}")
        sys.exit(1)
        
    ebuilds = [f for f in os.listdir(pkg_dir) if f.startswith(f"{name}-") and f.endswith(".ebuild")]
    if not ebuilds:
        print(f"Error: No ebuilds found for {category}/{name}")
        sys.exit(1)
        
    ebuilds.sort()
    return os.path.join(pkg_dir, ebuilds[-1])

def get_github_repo_url(ebuild_content):
    matches = re.findall(r'https://github\.com/([^/"\s]+)/([^/"\s\->]+)', ebuild_content)
    for owner, repo in matches:
        repo = repo.replace(".tar.gz", "").replace(".zip", "").split("->")[0].strip()
        if "deps" not in repo and "depfiles" not in repo:
            return f"https://github.com/{owner}/{repo}.git"
    return None

def get_tag_commit(repo_url, version):
    for tag_name in [f"v{version}", version]:
        try:
            cmd = ["git", "ls-remote", "--tags", repo_url, f"refs/tags/{tag_name}"]
            res = subprocess.run(cmd, capture_output=True, text=True, check=True)
            output = res.stdout.strip()
            if output:
                parts = output.split()
                if len(parts) >= 2:
                    return parts[0]
        except Exception as e:
            print(f"Warning: Failed to fetch commit for tag {tag_name}: {e}")
    return None

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Update Go ebuild version.")
    parser.add_argument("--category", required=True)
    parser.add_argument("--name", required=True)
    parser.add_argument("--version", required=True)
    args = parser.parse_args()
    
    category = args.category
    name = args.name
    version = args.version
    
    latest_ebuild_path = find_latest_ebuild(category, name)
    print(f"Latest existing ebuild: {latest_ebuild_path}")
    
    with open(latest_ebuild_path, "r", encoding="utf-8") as f:
        ebuild_content = f.read()
        
    pkg_dir = os.path.dirname(latest_ebuild_path)
    new_ebuild_name = f"{name}-{version}.ebuild"
    new_ebuild_path = os.path.join(pkg_dir, new_ebuild_name)
    print(f"New ebuild path: {new_ebuild_path}")
    
    # Copy old content
    updated_content = ebuild_content
    
    # Update VERSION_GIT_HASH if present (e.g. chezmoi)
    github_url = get_github_repo_url(ebuild_content)
    if github_url and "VERSION_GIT_HASH" in ebuild_content:
        print(f"Querying commit hash for tag v{version}...")
        commit_hash = get_tag_commit(github_url, version)
        if commit_hash:
            print(f"Found commit hash: {commit_hash}")
            updated_content = re.sub(
                r'VERSION_GIT_HASH="[^"]*"', 
                f'VERSION_GIT_HASH="{commit_hash}"', 
                updated_content
            )
            
    # Write new ebuild
    with open(new_ebuild_path, "w", encoding="utf-8") as f:
        f.write(updated_content)
        
    # Generate manifest (will try to download deps.tar.xz from remote server)
    print("Regenerating Portage Manifest...")
    try:
        subprocess.run(["ebuild", new_ebuild_name, "manifest"], cwd=pkg_dir, check=True)
        print("Manifest regenerated successfully.")
        
        # Remove the old ebuild
        if latest_ebuild_path != new_ebuild_path:
            os.remove(latest_ebuild_path)
            print(f"Removed older ebuild: {latest_ebuild_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error: Manifest generation failed (likely because dependencies are not uploaded yet): {e}")
        if os.path.exists(new_ebuild_path):
            os.remove(new_ebuild_path)
        sys.exit(1)

if __name__ == "__main__":
    main()
