#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Gentoo Overlay Update & Maintenance Script
Author: Antigravity Code Assistant
"""

import os
import sys
import re
import urllib.request
import urllib.error
import subprocess
import argparse
import ssl

# Configuration
REPO_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Configure SSL context to be lenient if user has certificates issues
ssl_context = ssl._create_unverified_context() if hasattr(ssl, '_create_unverified_context') else None

def fetch_url(url):
    """Fetches a URL and returns its content as a string."""
    try:
        req = urllib.request.Request(
            url, 
            headers={'User-Agent': 'Mozilla/5.0 (Gentoo Linux; Antigravity Updater)'}
        )
        context_arg = {"context": ssl_context} if ssl_context else {}
        with urllib.request.urlopen(req, timeout=15, **context_arg) as response:
            return response.read().decode('utf-8', errors='ignore')
    except Exception as e:
        print(f"Error fetching URL {url}: {e}")
        return None

def parse_version(v_str):
    """Parses a version string into a tuple of tuples to prevent mixing of types during comparison."""
    cleaned = re.sub(r'[^0-9a-zA-Z.]', '.', v_str)
    parts = cleaned.split('.')
    parsed = []
    for p in parts:
        if p.isdigit():
            parsed.append((0, int(p)))
        else:
            parsed.append((1, p))
    return tuple(parsed)

def get_git_tags(url, prefix="", exclude_prerelease=False, pattern=None):
    """Fetches tags from a remote git repository using git ls-remote."""
    try:
        cmd = ["git", "ls-remote", "--tags", url]
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        tags = []
        for line in res.stdout.strip().split("\n"):
            if not line:
                continue
            parts = line.split("\t")
            if len(parts) < 2:
                continue
            ref = parts[1]
            # Match refs/tags/<prefix><version> starting strictly with a digit after the prefix
            match = re.match(r'^refs/tags/' + re.escape(prefix) + r'([0-9].*)$', ref)
            if match:
                tag_ver = match.group(1)
                # Ignore tag wrappers like ^{}
                if not tag_ver.endswith("^{}"):
                    if pattern and not re.match(pattern, tag_ver):
                        continue
                    if exclude_prerelease:
                        # Skip alpha, beta, rc, pre, dev, test
                        if re.search(r'[-.](alpha|beta|rc|pre|dev|test)\b', tag_ver, re.IGNORECASE):
                            continue
                    tags.append(tag_ver)
        tags = list(set(tags))
        tags.sort(key=parse_version, reverse=True)
        return tags
    except Exception as e:
        print(f"Error fetching git tags from {url}: {e}")
        return []

def get_local_version(category, name):
    """Detects the latest version of a package currently in the local overlay."""
    pkg_dir = os.path.join(REPO_DIR, category, name)
    if not os.path.isdir(pkg_dir):
        return None, None
    ebuilds = [f for f in os.listdir(pkg_dir) if f.endswith(".ebuild")]
    if not ebuilds:
        return None, None
        
    # Special handling for hqplayerd-bin: only track 6.x series
    if name == "hqplayerd-bin":
        ebuilds = [f for f in ebuilds if f.startswith("hqplayerd-bin-6.")]
        
    versions = []
    for eb in ebuilds:
        # ebuild filename format: <name>-<version>.ebuild
        ver_str = eb[len(name)+1:-7]
        versions.append((parse_version(ver_str), ver_str, eb))
    if not versions:
        return None, None
    versions.sort(reverse=True)
    return versions[0][1], versions[0][2]

def get_main_tree_portage_version():
    """Finds the latest stable version of sys-apps/portage in the main Gentoo tree."""
    main_dir = "/var/db/repos/gentoo/sys-apps/portage"
    if not os.path.isdir(main_dir):
        return None
    ebuilds = [f for f in os.listdir(main_dir) if f.endswith(".ebuild")]
    stable_versions = []
    for eb in ebuilds:
        if eb == "portage-9999.ebuild":
            continue
        ver_str = eb[len("portage")+1:-7]
        eb_path = os.path.join(main_dir, eb)
        try:
            with open(eb_path, "r", encoding="utf-8") as f:
                content = f.read()
            # Check KEYWORDS for stable (contains "amd64", not "~amd64")
            keywords_match = re.search(r'\bKEYWORDS="([^"]+)"', content)
            if keywords_match:
                keywords = keywords_match.group(1).split()
                if "amd64" in keywords:
                    stable_versions.append((parse_version(ver_str), ver_str))
        except Exception as e:
            print(f"Error reading main tree ebuild {eb_path}: {e}")
            
    if not stable_versions:
        return None
    stable_versions.sort(reverse=True)
    return stable_versions[0][1]

def patch_portage_ebuild(content):
    """Applies local overlay customizations to a main tree Portage ebuild."""
    if "getuto" in content and "debug" in content:
        return content
        
    if "app-portage/getuto" not in content or "dev-util/debugedit" not in content:
        print("Warning: Expected dependency patterns not found in portage ebuild. Copying as is.")
        return content
        
    # Replace dependencies with conditionals
    content = content.replace("app-portage/getuto", "getuto? (\n\t\tapp-portage/getuto\n\t)")
    content = content.replace("dev-util/debugedit", "debug? (\n\t\tdev-util/debugedit\n\t)")
    
    # Add getuto and debug to IUSE
    content = re.sub(r'IUSE=(["\'])([^"\']*?xattr[^"\']*?)\1', r'IUSE=\1\2 getuto debug\1', content)
    return content

# ── Upstream Version Checkers ──────────────────────────────────────────────────

def check_git_commit_upstream(url, ref="HEAD"):
    """Gets the latest commit hash for a given git repository URL and ref."""
    try:
        cmd = ["git", "ls-remote", url, ref]
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        if res.stdout:
            parts = res.stdout.strip().split()
            if parts:
                return parts[0]
    except Exception as e:
        print(f"Error fetching git commit from {url}: {e}")
    return None

def check_github_upstream(url, prefix, exclude_prerelease=False, pattern=None):
    tags = get_git_tags(url, prefix, exclude_prerelease, pattern)
    return tags[0] if tags else None

def check_claude_code_upstream():
    tags = get_git_tags("https://github.com/anthropics/claude-code.git", "v")
    return tags[0] if tags else None

def check_gitstatus_upstream():
    tags = get_git_tags("https://github.com/romkatv/gitstatus.git", "v")
    return tags[0] if tags else None

def check_lm_sensors_upstream():
    # Tag is V3-6-2 -> maps to 3.6.2
    tags = get_git_tags("https://github.com/hramrach/lm-sensors.git", "V")
    if tags:
        return tags[0].replace("-", ".")
    return None

def check_roonserver_upstream():
    url = "https://updates.roonlabs.net/update/?v=2&platform=linux&version=&product=RoonServer&branding=roon&branch=production&curbranch=production"
    resp = fetch_url(url)
    if not resp:
        return None
    match = re.search(r'displayversion=([0-9.]+)\s+\(build\s+([0-9]+)\)', resp)
    if match:
        return match.group(1)
    return None

def check_naa_bin_upstream():
    url = "https://www.signalyst.com/bins/naa/linux/noble/"
    resp = fetch_url(url)
    if not resp:
        return None
    matches = re.findall(r'networkaudiod_([0-9.]+)-([0-9]+)_amd64\.deb', resp)
    if matches:
        versions = [f"{m[0]}.{m[1]}" for m in matches]
        versions.sort(key=parse_version, reverse=True)
        return versions[0]
    return None

def check_hqplayerd_bin_upstream():
    url = "https://www.signalyst.eu/bins/hqplayerd/noble/"
    resp = fetch_url(url)
    if not resp:
        return None
    # We only update 6.x series
    matches = re.findall(r'hqplayerd_(6\.[0-9.]+)-([0-9]+)_amd64\.deb', resp)
    if matches:
        versions = [f"{m[0]}.{m[1]}" for m in matches]
        versions.sort(key=parse_version, reverse=True)
        return versions[0]
    return None

def check_raat_app_bin_upstream():
    url = "https://debianrepo.hifiberry.com/pool/trixie/main/h/hifiberry-raat/"
    resp = fetch_url(url)
    if not resp:
        return None
    matches = re.findall(r'hifiberry-raat_([0-9.]+)_arm64\.deb', resp)
    if matches:
        matches = list(set(matches))
        matches.sort(key=parse_version, reverse=True)
        return matches[0]
    return None

def check_diretta_upstream(prefix):
    url = "https://www.audio-linux.com/repo_aarch64/"
    resp = fetch_url(url)
    if not resp:
        return None
    pattern = re.escape(prefix) + r'([0-9]+)_([0-9]+)-([0-9]+)-aarch64\.pkg\.tar\.xz'
    matches = re.findall(pattern, resp)
    if matches:
        versions = [f"{m[0]}.{m[1]}.{m[2]}" for m in matches]
        versions.sort(key=parse_version, reverse=True)
        return versions[0]
    return None

def check_mac_upstream():
    url = "http://www.deb-multimedia.org/pool/main/m/monkeys-audio/"
    resp = fetch_url(url)
    if not resp:
        return None
    matches = re.findall(r'monkeys-audio_([0-9a-zA-Z.-]+)\.orig\.tar\.gz', resp)
    if matches:
        versions = []
        for m in matches:
            match = re.match(r'([0-9.]+)-u([0-9.]+)-b([0-9.]+)-s([0-9.]+)', m)
            if match:
                ver = f"{match.group(1)}.{match.group(2)}.{match.group(3)}.{match.group(4)}"
                versions.append(ver)
        if versions:
            versions.sort(key=parse_version, reverse=True)
            return versions[0]
    return None

def check_libgmpris_upstream():
    url = "https://www.sonarnerd.net/src/focal/src/"
    resp = fetch_url(url)
    if not resp:
        return None
    matches = re.findall(r'libgmpris_([0-9.]+)-([0-9]+)\.tar\.gz', resp)
    if matches:
        versions = [m[0] for m in matches]
        versions.sort(key=parse_version, reverse=True)
        return versions[0]
    return None

def get_main_tree_kernel_version():
    main_dir = "/var/db/repos/gentoo/sys-kernel/gentoo-sources"
    if not os.path.isdir(main_dir):
        return None
    ebuilds = [f for f in os.listdir(main_dir) if f.endswith(".ebuild")]
    stable_versions = []
    for eb in ebuilds:
        if eb == "gentoo-sources-9999.ebuild":
            continue
        ver_str = eb[len("gentoo-sources")+1:-7]
        eb_path = os.path.join(main_dir, eb)
        try:
            with open(eb_path, "r", encoding="utf-8") as f:
                content = f.read()
            keywords_match = re.search(r'\bKEYWORDS="([^"]+)"', content)
            if keywords_match:
                keywords = keywords_match.group(1).split()
                if "amd64" in keywords:
                    stable_versions.append((parse_version(ver_str), ver_str))
        except Exception:
            pass
    if stable_versions:
        stable_versions.sort(reverse=True)
        return stable_versions[0][1]
    return None

def check_gitstatus_extra_patch(new_ebuild_path, new_version):
    """Pulls gitstatus build.info and updates LIBGIT2_TAG in the ebuild."""
    build_info_url = f"https://raw.githubusercontent.com/romkatv/gitstatus/v{new_version}/build.info"
    build_info = fetch_url(build_info_url)
    if not build_info:
        print(f"Error: Could not fetch build.info for gitstatus v{new_version}")
        return False
    match = re.search(r'libgit2_version="([^"]+)"', build_info)
    if not match:
        print(f"Error: Could not parse libgit2_version from build.info")
        return False
    libgit2_tag = match.group(1)
    
    with open(new_ebuild_path, "r", encoding="utf-8") as f:
        content = f.read()
    content = re.sub(r'LIBGIT2_TAG="[^"]+"', f'LIBGIT2_TAG="{libgit2_tag}"', content)
    with open(new_ebuild_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print(f"Updated LIBGIT2_TAG to {libgit2_tag} in {new_ebuild_path}")
    return True

# ── Portage Patches ───────────────────────────────────────────────────────────

def update_portage_ebuild(new_ebuild_path, new_version):
    main_repo_ebuild = f"/var/db/repos/gentoo/sys-apps/portage/portage-{new_version}.ebuild"
    if not os.path.exists(main_repo_ebuild):
        print(f"Error: Portage stable ebuild {main_repo_ebuild} does not exist in main repository")
        return False
        
    try:
        with open(main_repo_ebuild, "r", encoding="utf-8") as f:
            content = f.read()
            
        patched_content = patch_portage_ebuild(content)
        
        # Add local PATCHES block if not present
        if '0001-Workaround-import-problem-after-Python-upgrade.patch' not in patched_content:
            inherit_match = re.search(r'\binherit\b.*', patched_content)
            if inherit_match:
                insert_pos = inherit_match.end()
                patches_block = '\n\nPATCHES=(\n\t"${FILESDIR}/0001-Workaround-import-problem-after-Python-upgrade.patch"\n)'
                patched_content = patched_content[:insert_pos] + patches_block + patched_content[insert_pos:]
                
        with open(new_ebuild_path, "w", encoding="utf-8") as f:
            f.write(patched_content)
        return True
    except Exception as e:
        print(f"Error patching portage ebuild: {e}")
        return False

# ── Manifest & Git Operations ─────────────────────────────────────────────────

def run_ebuild_manifest(ebuild_path):
    """Runs ebuild manifest on the target ebuild."""
    try:
        pkg_dir = os.path.dirname(ebuild_path)
        ebuild_file = os.path.basename(ebuild_path)
        cmd = ["ebuild", ebuild_file, "manifest"]
        res = subprocess.run(cmd, cwd=pkg_dir, capture_output=True, text=True, check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error running ebuild manifest on {ebuild_path}:")
        print(e.stderr)
        return False

# ── Main Updater Logic ─────────────────────────────────────────────────────────

def run_update():
    parser = argparse.ArgumentParser(description="Update Gentoo Overlay Packages.")
    parser.add_argument("--dry-run", action="store_true", help="Find updates without applying them.")
    args = parser.parse_args()
    
    packages = {
        # Auto-updatable:
        "dev-util/antigravity-cli": {"type": "github", "url": "https://github.com/google-antigravity/antigravity-cli.git", "prefix": ""},
        "dev-util/codex-bin": {"type": "github", "url": "https://github.com/openai/codex.git", "prefix": "rust-v", "exclude_prerelease": True},
        "dev-util/claude-code": {"type": "claude_code"},
        "app-shells/zsh-autosuggestions": {"type": "github", "url": "https://github.com/zsh-users/zsh-autosuggestions.git", "prefix": "v"},
        "app-shells/zsh-theme-powerlevel10k": {"type": "github", "url": "https://github.com/romkatv/powerlevel10k.git", "prefix": "v"},
        "app-shells/gitstatus": {"type": "gitstatus"},
        "sys-process/htop": {"type": "github", "url": "https://github.com/htop-dev/htop.git", "prefix": ""},
        "sys-process/nvtop": {"type": "github", "url": "https://github.com/Syllo/nvtop.git", "prefix": ""},
        "dev-libs/libsensors": {"type": "lm-sensors"},
        "media-libs/alac": {"type": "github", "url": "https://github.com/mikebrady/alac.git", "prefix": ""},
        "media-sound/airupnp-bin": {"type": "github", "url": "https://github.com/philippe44/AirConnect.git", "prefix": ""},
        "dev-vcs/lazygit": {"type": "github", "url": "https://github.com/jesseduffield/lazygit.git", "prefix": "v"},
        "media-sound/roonserver": {"type": "roonserver"},
        "media-sound/naa-bin": {"type": "naa_bin"},
        "media-sound/hqplayerd-bin": {"type": "hqplayerd_bin"},
        "media-sound/raat-app-bin": {"type": "raat_app_bin"},
        "media-sound/diretta-direct-module": {"type": "diretta_module", "prefix": "diretta-direct-dkms-"},
        "media-sound/diretta-alsa-module": {"type": "diretta_module", "prefix": "diretta-alsa-dkms-"},
        "media-sound/diretta-alsa-target": {"type": "diretta_module", "prefix": "diretta-alsa-target-"},
        "media-sound/diretta-memory-player": {"type": "diretta_module", "prefix": "diretta-memory-player-"},
        "media-sound/diretta-alsa-host": {"type": "diretta_module", "prefix": "diretta-alsa-daemon-"},
        "sys-apps/portage": {"type": "portage"},
        "media-sound/sacd-extract": {"type": "github", "url": "https://github.com/EuFlo/sacd-ripper.git", "prefix": "", "exclude_prerelease": True, "pattern": r"^0\.3\."},
        
        # Auto-updatable:
        "app-admin/chezmoi": {"type": "go", "url": "https://github.com/twpayne/chezmoi.git", "prefix": "v"},
        "app-misc/yazi": {"type": "yazi", "url": "https://github.com/sxyazi/yazi.git", "prefix": "v"},
        
        # Notify-only / Excluded from auto-updates:
        "sys-kernel/networkaudio-sources": {"type": "networkaudio_sources"},
        "media-sound/mac": {"type": "mac"},
        "media-libs/libgmpris": {"type": "libgmpris"}
    }
    
    results = []
    
    for pkg_path, cfg in packages.items():
        category, name = pkg_path.split("/")
        local_ver, local_ebuild = get_local_version(category, name)
        
        if not local_ver:
            print(f"Skipping {pkg_path}: no local ebuild found.")
            continue
            
        print(f"Checking {pkg_path} (local: {local_ver})...")
        upstream_ver = None
        
        ptype = cfg["type"]
        if ptype in ("github", "go", "yazi"):
            exclude_pre = cfg.get("exclude_prerelease", False)
            tag_pattern = cfg.get("pattern", None)
            upstream_ver = check_github_upstream(cfg["url"], cfg["prefix"], exclude_pre, tag_pattern)
        elif ptype == "claude_code":
            upstream_ver = check_claude_code_upstream()
        elif ptype == "gitstatus":
            upstream_ver = check_gitstatus_upstream()
        elif ptype == "lm-sensors":
            upstream_ver = check_lm_sensors_upstream()
        elif ptype == "roonserver":
            upstream_ver = check_roonserver_upstream()
        elif ptype == "naa_bin":
            upstream_ver = check_naa_bin_upstream()
        elif ptype == "hqplayerd_bin":
            upstream_ver = check_hqplayerd_bin_upstream()
        elif ptype == "raat_app_bin":
            upstream_ver = check_raat_app_bin_upstream()
        elif ptype == "diretta_module":
            upstream_ver = check_diretta_upstream(cfg["prefix"])
        elif ptype == "portage":
            upstream_ver = get_main_tree_portage_version()
        elif ptype == "mac":
            upstream_ver = check_mac_upstream()
        elif ptype == "libgmpris":
            upstream_ver = check_libgmpris_upstream()
        elif ptype == "networkaudio_sources":
            upstream_ver = get_main_tree_kernel_version()
            if not upstream_ver:
                upstream_ver = local_ver
                
            # 1. Fetch latest values
            latest_cachy = check_git_commit_upstream("https://github.com/CachyOS/kernel-patches.git")
            latest_xanmod = check_git_commit_upstream("https://gitlab.com/xanmod/linux-patches.git")
            
            diretta_direct = check_diretta_upstream("diretta-direct-dkms-")
            latest_diretta_direct = diretta_direct.replace(".", "_") if diretta_direct else None
            
            diretta_alsa = check_diretta_upstream("diretta-alsa-dkms-")
            latest_diretta_alsa = diretta_alsa.replace(".", "_") if diretta_alsa else None
            
            # Read current ebuild
            pkg_dir = os.path.join(REPO_DIR, category, name)
            ebuild_path = os.path.join(pkg_dir, local_ebuild)
            
            try:
                with open(ebuild_path, "r", encoding="utf-8") as f:
                    content = f.read()
            except Exception as e:
                print(f"  Failed to read ebuild {local_ebuild}: {e}")
                results.append((pkg_path, local_ver, upstream_ver, f"Read failed: {e}", "red"))
                continue
                
            cachy_match = re.search(r'CACHY_COMMIT="([^"]+)"', content)
            xanmod_match = re.search(r'XANMOD_COMMIT="([^"]+)"', content)
            direct_match = re.search(r'DIRETTA_DIRECT_VER="([^"]+)"', content)
            alsa_match = re.search(r'DIRETTA_ALSA_VER="([^"]+)"', content)
            
            curr_cachy = cachy_match.group(1) if cachy_match else None
            curr_xanmod = xanmod_match.group(1) if xanmod_match else None
            curr_direct = direct_match.group(1) if direct_match else None
            curr_alsa = alsa_match.group(1) if alsa_match else None
            
            needs_update = False
            update_details = []
            
            if latest_cachy and latest_cachy != curr_cachy:
                needs_update = True
                update_details.append(f"Cachy: {curr_cachy[:8]}->{latest_cachy[:8]}")
            if latest_xanmod and latest_xanmod != curr_xanmod:
                needs_update = True
                update_details.append(f"Xanmod: {curr_xanmod[:8]}->{latest_xanmod[:8]}")
            if latest_diretta_direct and latest_diretta_direct != curr_direct:
                needs_update = True
                update_details.append(f"Diretta Direct: {curr_direct}->{latest_diretta_direct}")
            if latest_diretta_alsa and latest_diretta_alsa != curr_alsa:
                needs_update = True
                update_details.append(f"Diretta Alsa: {curr_alsa}->{latest_diretta_alsa}")
                
            has_kernel_bump = parse_version(upstream_ver) > parse_version(local_ver)
            
            status_parts = []
            if has_kernel_bump:
                status_parts.append(f"Kernel bump to {upstream_ver} available (manual)")
            
            if needs_update:
                if args.dry_run:
                    status_parts.append(f"Updates available: {', '.join(update_details)}")
                    results.append((pkg_path, local_ver, upstream_ver, "; ".join(status_parts), "green"))
                else:
                    new_content = content
                    if latest_cachy and curr_cachy:
                        new_content = re.sub(r'CACHY_COMMIT="[^"]+"', f'CACHY_COMMIT="{latest_cachy}"', new_content)
                    if latest_xanmod and curr_xanmod:
                        new_content = re.sub(r'XANMOD_COMMIT="[^"]+"', f'XANMOD_COMMIT="{latest_xanmod}"', new_content)
                    if latest_diretta_direct and curr_direct:
                        new_content = re.sub(r'DIRETTA_DIRECT_VER="[^"]+"', f'DIRETTA_DIRECT_VER="{latest_diretta_direct}"', new_content)
                    if latest_diretta_alsa and curr_alsa:
                        new_content = re.sub(r'DIRETTA_ALSA_VER="[^"]+"', f'DIRETTA_ALSA_VER="{latest_diretta_alsa}"', new_content)
                        
                    try:
                        with open(ebuild_path, "w", encoding="utf-8") as f:
                            f.write(new_content)
                        print(f"  Updated ebuild {local_ebuild} with new variables.")
                        
                        manifest_ok = run_ebuild_manifest(ebuild_path)
                        if manifest_ok:
                            status_parts.append(f"Updated: {', '.join(update_details)}")
                            results.append((pkg_path, local_ver, upstream_ver, "; ".join(status_parts), "green"))
                        else:
                            # Revert
                            with open(ebuild_path, "w", encoding="utf-8") as f:
                                f.write(content)
                            run_ebuild_manifest(ebuild_path)
                            status_parts.append("Manifest failed (rolled back)")
                            results.append((pkg_path, local_ver, upstream_ver, "; ".join(status_parts), "red"))
                    except Exception as e:
                        print(f"  Failed to update ebuild: {e}")
                        status_parts.append(f"Update failed: {e}")
                        results.append((pkg_path, local_ver, upstream_ver, "; ".join(status_parts), "red"))
            else:
                if not status_parts:
                    status_parts.append("Up to date")
                results.append((pkg_path, local_ver, upstream_ver, "; ".join(status_parts), "cyan" if not has_kernel_bump else "yellow"))
            continue
        elif ptype == "notify_only":
            if cfg["url"] == "gentoo-sources":
                upstream_ver = get_main_tree_kernel_version()
            elif "github.com" in cfg["url"]:
                exclude_pre = cfg.get("exclude_prerelease", False)
                tag_pattern = cfg.get("pattern", None)
                upstream_ver = check_github_upstream(cfg["url"], cfg["prefix"], exclude_pre, tag_pattern)
        
        if not upstream_ver:
            print(f"  Could not determine upstream version.")
            results.append((pkg_path, local_ver, "Unknown", "Error checking upstream", "red"))
            continue
            
        print(f"  Upstream: {upstream_ver}")
        
        if parse_version(upstream_ver) > parse_version(local_ver):
            if ptype in ("notify_only", "mac", "libgmpris"):
                reason = cfg.get("reason", "Needs manual verification / non-automatable package")
                if ptype == "mac":
                    reason = "Sourced from deb-multimedia archive which rarely updates"
                elif ptype == "libgmpris":
                    reason = "Static source archive from Signalyst"
                print(f"  [Notify Only] Update available: {upstream_ver}. Reason: {reason}")
                results.append((pkg_path, local_ver, upstream_ver, f"Notify Only: {reason}", "yellow"))
            else:
                print(f"  [Update Pending] Found newer version: {upstream_ver}")
                if args.dry_run:
                    results.append((pkg_path, local_ver, upstream_ver, "Update available (dry-run)", "green"))
                else:
                    pkg_dir = os.path.join(REPO_DIR, category, name)
                    new_ebuild_name = f"{name}-{upstream_ver}.ebuild"
                    new_ebuild_path = os.path.join(pkg_dir, new_ebuild_name)
                    old_ebuild_path = os.path.join(pkg_dir, local_ebuild)
                    
                    env = os.environ.copy()
                    
                    if ptype == "go":
                        print(f"  Running update_go_ebuild.py to update Go package {name} to {upstream_ver}...")
                        try:
                            cmd = [
                                sys.executable,
                                os.path.join(REPO_DIR, "scripts", "update_go_ebuild.py"),
                                "--category", category,
                                "--name", name,
                                "--version", upstream_ver
                            ]
                            subprocess.run(cmd, env=env, check=True)
                            results.append((pkg_path, local_ver, upstream_ver, "Updated successfully", "green"))
                            continue
                        except Exception as e:
                            print(f"  Failed to update Go ebuild: {e}")
                            results.append((pkg_path, local_ver, upstream_ver, "Go update failed", "red"))
                            continue
                            
                    elif ptype == "yazi":
                        print(f"  Running update_yazi_ebuild.py to update Rust package {name} to {upstream_ver}...")
                        try:
                            import shutil
                            shutil.copy2(old_ebuild_path, new_ebuild_path)
                            cmd = [
                                sys.executable,
                                os.path.join(REPO_DIR, "scripts", "update_yazi_ebuild.py"),
                                "--ebuild", new_ebuild_path
                            ]
                            subprocess.run(cmd, env=env, check=True)
                            os.remove(old_ebuild_path)
                            results.append((pkg_path, local_ver, upstream_ver, "Updated successfully", "green"))
                            continue
                        except Exception as e:
                            print(f"  Failed to update Yazi ebuild: {e}")
                            if os.path.exists(new_ebuild_path):
                                os.remove(new_ebuild_path)
                            results.append((pkg_path, local_ver, upstream_ver, "Rust update failed", "red"))
                            continue
                            
                    success = True
                    
                    if ptype == "portage":
                        success = update_portage_ebuild(new_ebuild_path, upstream_ver)
                    else:
                        try:
                            with open(old_ebuild_path, "r", encoding="utf-8") as sf:
                                eb_content = sf.read()
                            with open(new_ebuild_path, "w", encoding="utf-8") as df:
                                df.write(eb_content)
                            print(f"  Copied ebuild to {new_ebuild_name}")
                        except Exception as e:
                            print(f"  Failed to copy ebuild: {e}")
                            success = False
                            
                    if success and ptype == "gitstatus":
                        success = check_gitstatus_extra_patch(new_ebuild_path, upstream_ver)
                        
                    if success:
                        print(f"  Regenerating manifest for {new_ebuild_name}...")
                        manifest_ok = run_ebuild_manifest(new_ebuild_path)
                        if manifest_ok:
                            os.remove(old_ebuild_path)
                            print(f"  Successfully updated to {upstream_ver} and removed old ebuild.")
                            results.append((pkg_path, local_ver, upstream_ver, "Updated successfully", "green"))
                        else:
                            if os.path.exists(new_ebuild_path):
                                os.remove(new_ebuild_path)
                            print(f"  Manifest failed. Rolled back changes.")
                            results.append((pkg_path, local_ver, upstream_ver, "Manifest failed (rolled back)", "red"))
                    else:
                        if os.path.exists(new_ebuild_path):
                            os.remove(new_ebuild_path)
                        results.append((pkg_path, local_ver, upstream_ver, "Copy/Patch failed", "red"))
        else:
            print(f"  Already up-to-date.")
            results.append((pkg_path, local_ver, upstream_ver, "Up to date", "cyan"))
            
    print("\n" + "="*80)
    print(f"{'PACKAGE UPDATE SUMMARY':^80}")
    print("="*80)
    print(f"{'Package':<35} | {'Local':<12} | {'Upstream':<12} | {'Status/Action'}")
    print("-"*80)
    for pkg, lv, uv, status, color in results:
        print(f"{pkg:<35} | {lv:<12} | {uv:<12} | {status}")
    print("="*80)

if __name__ == "__main__":
    run_update()
