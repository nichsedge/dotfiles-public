#!/usr/bin/env bash
set -euo pipefail

# Antigravity Updater for Linux (Fedora / GNOME)
# Scrapes latest releases from https://antigravity.google/releases using Python,
# downloads verified tarballs, replaces old versions in ~/bin, and updates symlinks.

INSTALL_DIR="${INSTALL_DIR:-$HOME/bin}"
PLATFORM="linux-x64"

# Component paths
IDE_DIR="$INSTALL_DIR/Antigravity IDE"
IDE_SYMLINK="$INSTALL_DIR/antigravity-ide"
HUB_DIR="$INSTALL_DIR/Antigravity-x64"
HUB_SYMLINK="$INSTALL_DIR/antigravity"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}→${NC} $1"; }
info() { echo -e "${CYAN}ℹ${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
err()  { echo -e "${RED}✗${NC} $1" >&2; }

# Python helper to scrape releases from https://antigravity.google/releases
fetch_releases_python() {
    python3 - "$@" << 'EOF'
import urllib.request, gzip, json, html, re, sys

def fetch_releases():
    html_content = ""
    try:
        req = urllib.request.Request(
            "https://antigravity.google/releases",
            headers={"User-Agent": "Mozilla/5.0 (X11; Linux x86_64)"}
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            raw = resp.read()
            try:
                html_content = gzip.decompress(raw).decode("utf-8")
            except Exception:
                html_content = raw.decode("utf-8", errors="ignore")
    except Exception:
        pass

    hub_list = []
    ide_list = []

    # 1. Scrape from releases page HTML data attributes
    m_hub = re.search(r'data-static-versions=[\"\']([^\"\']+)[\"\']', html_content)
    if m_hub:
        try:
            hub_list = json.loads(html.unescape(m_hub.group(1)))
        except Exception:
            pass

    m_ide = re.search(r'data-fallback-ide=[\"\']([^\"\']+)[\"\']', html_content)
    if m_ide:
        try:
            ide_list = json.loads(html.unescape(m_ide.group(1)))
        except Exception:
            pass

    # 2. Fallback to Cloud Run auto-updater endpoints if needed
    if not hub_list:
        try:
            req = urllib.request.Request(
                "https://antigravity-hub-auto-updater-974169037036.us-central1.run.app/releases",
                headers={"User-Agent": "Mozilla/5.0"}
            )
            with urllib.request.urlopen(req, timeout=10) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                hub_list = data if isinstance(data, list) else data.get("versions", [])
        except Exception:
            pass

    if not ide_list:
        try:
            req = urllib.request.Request(
                "https://antigravity-ide-auto-updater-974169037036.us-central1.run.app/releases",
                headers={"User-Agent": "Mozilla/5.0"}
            )
            with urllib.request.urlopen(req, timeout=10) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                ide_list = data if isinstance(data, list) else data.get("versions", [])
        except Exception:
            pass

    def is_v2_plus(item):
        try:
            return int(str(item.get("version", "0")).split(".")[0]) >= 2
        except Exception:
            return False

    hub_v2 = [x for x in hub_list if is_v2_plus(x)]
    ide_v2 = [x for x in ide_list if is_v2_plus(x)]

    action = sys.argv[1] if len(sys.argv) > 1 else "latest"
    target = sys.argv[2] if len(sys.argv) > 2 else "all"

    if action == "list":
        res = {}
        if target in ("hub", "all"):
            res["hub"] = [x.get("version") for x in hub_v2]
        if target in ("ide", "all"):
            res["ide"] = [x.get("version") for x in ide_v2]
        print(json.dumps(res))
        return

    # Helper to build download info
    def get_info(comp, ver_query=None):
        pool = ide_v2 if comp == "ide" else hub_v2
        selected = None
        if ver_query and ver_query != "latest":
            for x in pool:
                if x.get("version") == ver_query or f"{x.get('version')}-{x.get('execution_id')}" == ver_query:
                    selected = x
                    break
            if not selected:
                if "-" in ver_query:
                    parts = ver_query.split("-", 1)
                    selected = {"version": parts[0], "execution_id": parts[1]}
        else:
            if pool:
                selected = pool[0]

        if not selected:
            return None

        ver = selected.get("version")
        eid = selected.get("execution_id", "")
        if comp == "ide":
            url = f"https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/{ver}-{eid}/linux-x64/Antigravity%20IDE.tar.gz"
            return {
                "component": "ide",
                "name": "Antigravity IDE",
                "version": ver,
                "execution_id": eid,
                "url": url,
                "tar_name": "Antigravity IDE.tar.gz",
                "extract_dir": "Antigravity IDE",
                "binary": "antigravity-ide",
                "bin_subpath": "bin/antigravity-ide"
            }
        else:
            url = f"https://storage.googleapis.com/antigravity-public/antigravity-hub/{ver}-{eid}/linux-x64/Antigravity.tar.gz"
            return {
                "component": "hub",
                "name": "Antigravity (Hub)",
                "version": ver,
                "execution_id": eid,
                "url": url,
                "tar_name": "Antigravity.tar.gz",
                "extract_dir": "Antigravity-x64",
                "binary": "antigravity",
                "bin_subpath": "antigravity"
            }

    if action in ("get", "latest"):
        out = {}
        if target in ("hub", "all"):
            val = get_info("hub", sys.argv[3] if len(sys.argv) > 3 else None)
            if val: out["hub"] = val
        if target in ("ide", "all"):
            val = get_info("ide", sys.argv[3] if len(sys.argv) > 3 else None)
            if val: out["ide"] = val
        print(json.dumps(out))

fetch_releases()
EOF
}

# Get current installed IDE version
get_ide_version() {
    local prod="$IDE_DIR/resources/app/product.json"
    local ver_file="$IDE_DIR/version.txt"
    if [[ -f "$prod" ]]; then
        python3 -c 'import json, sys; print(json.load(open(sys.argv[1])).get("ideVersion", "?"))' "$prod" 2>/dev/null || cat "$ver_file" 2>/dev/null || echo "?"
    elif [[ -f "$ver_file" ]]; then
        cat "$ver_file"
    else
        echo "not_installed"
    fi
}

# Get current installed Antigravity Desktop App (Hub) version
get_hub_version() {
    local asar="$HUB_DIR/resources/app.asar"
    local ver_file="$HUB_DIR/version.txt"
    if [[ -f "$ver_file" ]]; then
        cat "$ver_file"
    elif [[ -f "$asar" ]]; then
        python3 - "$asar" << 'EOF'
import os, re, sys
asar_path = sys.argv[1]
if os.path.exists(asar_path):
    with open(asar_path, "rb") as f:
        content = f.read()
        idx = content.find(b'"name": "antigravity"')
        if idx != -1:
            chunk = content[idx:idx+200]
            m = re.search(rb'"version"\s*:\s*"([0-9\.]+)"', chunk)
            if m:
                print(m.group(1).decode())
                sys.exit(0)
print("unknown")
EOF
    else
        echo "not_installed"
    fi
}

# Get version for Antigravity CLI (agy)
get_agy_version() {
    if command -v agy &>/dev/null; then
        agy --version 2>/dev/null || echo "?"
    elif [[ -x "$HOME/.local/bin/agy" ]]; then
        "$HOME/.local/bin/agy" --version 2>/dev/null || echo "?"
    else
        echo "not_installed"
    fi
}

# Check status of all installed components against latest scraped releases
check_update() {
    log "Checking Antigravity components installed on system:"
    echo ""
    printf "  %-24s %-14s %-14s %s\n" "Component" "Installed" "Latest" "Status"
    printf "  %-24s %-14s %-14s %s\n" "---------" "---------" "------" "------"

    local meta
    meta="$(fetch_releases_python latest all)"
    
    local hub_latest ide_latest
    hub_latest="$(python3 -c 'import json, sys; d=json.loads(sys.argv[1]); print(d.get("hub",{}).get("version","?"))' "$meta")"
    ide_latest="$(python3 -c 'import json, sys; d=json.loads(sys.argv[1]); print(d.get("ide",{}).get("version","?"))' "$meta")"

    local cli_cur; cli_cur="$(get_agy_version)"
    local hub_cur; hub_cur="$(get_hub_version)"
    local ide_cur; ide_cur="$(get_ide_version)"

    is_outdated() {
        local cur="$1" latest="$2"
        if [[ "$cur" == "not_installed" ]]; then
            echo -e "${YELLOW}not installed${NC}"
        elif [[ "$latest" == "?" || "$cur" == "?" || "$cur" == "unknown" ]]; then
            echo -e "${YELLOW}unknown${NC}"
        elif [[ "$cur" == "$latest" ]]; then
            echo -e "${GREEN}up to date${NC}"
        elif [[ "$(printf '%s\n%s\n' "$cur" "$latest" | sort -V | head -n1)" != "$latest" ]]; then
            echo -e "${YELLOW}update available${NC}"
        else
            echo -e "${GREEN}up to date${NC}"
        fi
    }

    printf "  %-24s %-14s %-14s %b\n" "antigravity (Hub)" "$hub_cur" "$hub_latest" "$(is_outdated "$hub_cur" "$hub_latest")"
    printf "  %-24s %-14s %-14s %b\n" "antigravity-ide (IDE)" "$ide_cur" "$ide_latest" "$(is_outdated "$ide_cur" "$ide_latest")"
    printf "  %-24s %-14s %-14s %b\n" "agy (CLI)" "$cli_cur" "-" "${GREEN}active${NC}"
    echo ""
}

# Install or update a specific component
# Arguments: <ide|hub> [version]
install_component() {
    local comp="$1"
    local req_version="${2:-latest}"

    info "Fetching release info for '$comp' ($req_version) from https://antigravity.google/releases..."
    local meta
    meta="$(fetch_releases_python get "$comp" "$req_version")"

    local ver eid url tar_name extract_dirname binary bin_subpath
    ver="$(python3 -c 'import json, sys; d=json.loads(sys.argv[1]); print(d.get(sys.argv[2],{}).get("version",""))' "$meta" "$comp")"
    eid="$(python3 -c 'import json, sys; d=json.loads(sys.argv[1]); print(d.get(sys.argv[2],{}).get("execution_id",""))' "$meta" "$comp")"
    url="$(python3 -c 'import json, sys; d=json.loads(sys.argv[1]); print(d.get(sys.argv[2],{}).get("url",""))' "$meta" "$comp")"
    tar_name="$(python3 -c 'import json, sys; d=json.loads(sys.argv[1]); print(d.get(sys.argv[2],{}).get("tar_name",""))' "$meta" "$comp")"
    extract_dirname="$(python3 -c 'import json, sys; d=json.loads(sys.argv[1]); print(d.get(sys.argv[2],{}).get("extract_dir",""))' "$meta" "$comp")"
    binary="$(python3 -c 'import json, sys; d=json.loads(sys.argv[1]); print(d.get(sys.argv[2],{}).get("binary",""))' "$meta" "$comp")"
    bin_subpath="$(python3 -c 'import json, sys; d=json.loads(sys.argv[1]); print(d.get(sys.argv[2],{}).get("bin_subpath",""))' "$meta" "$comp")"

    if [[ -z "$url" || -z "$ver" ]]; then
        err "Could not resolve release info for $comp version '$req_version'"
        exit 1
    fi

    local target_dir="$INSTALL_DIR/$extract_dirname"
    local symlink_path="$INSTALL_DIR/$binary"

    local tmpdir
    tmpdir="$(mktemp -d)"
    local tar_path="$tmpdir/$tar_name"

    log "Downloading $extract_dirname $ver..."
    info "URL: $url"

    if curl -#fL --connect-timeout 30 -o "$tar_path" "$url"; then
        log "Download successful ($(du -h "$tar_path" | cut -f1))"
    else
        err "Download failed — check connection or URL: $url"
        rm -rf "$tmpdir"
        exit 1
    fi

    # Verify tarball integrity
    log "Verifying archive integrity..."
    if ! tar -tzf "$tar_path" >/dev/null 2>&1; then
        err "Downloaded archive is corrupted or invalid"
        rm -rf "$tmpdir"
        exit 1
    fi

    # Remove old version if present
    if [[ -d "$target_dir" ]]; then
        log "Removing old version at $target_dir..."
        rm -rf "$target_dir"
    fi

    # Extract directly into $INSTALL_DIR (archives contain the root directory)
    log "Extracting to $INSTALL_DIR/$extract_dirname..."
    mkdir -p "$INSTALL_DIR"
    tar -xzf "$tar_path" -C "$INSTALL_DIR"

    # Verify extraction
    if [[ ! -d "$target_dir" ]]; then
        err "Extraction failed: expected directory $target_dir not found"
        rm -rf "$tmpdir"
        exit 1
    fi

    # Ensure executable permissions
    log "Configuring permissions..."
    chmod +x "$target_dir/$binary" 2>/dev/null || true
    if [[ -f "$target_dir/$bin_subpath" ]]; then
        chmod +x "$target_dir/$bin_subpath" 2>/dev/null || true
    fi
    if [[ -f "$target_dir/chrome-sandbox" ]]; then
        chmod 4755 "$target_dir/chrome-sandbox" 2>/dev/null || chmod +x "$target_dir/chrome-sandbox" 2>/dev/null || true
    fi

    # Update symlink
    log "Updating symlink at $symlink_path..."
    rm -f "$symlink_path"
    if [[ -f "$target_dir/$bin_subpath" ]]; then
        ln -sf "$target_dir/$bin_subpath" "$symlink_path"
    else
        ln -sf "$target_dir/$binary" "$symlink_path"
    fi

    # Save version record
    echo "$ver" > "$target_dir/version.txt"

    # Cleanup temp download
    rm -rf "$tmpdir"

    # Refresh desktop database & mime handler
    local app_dir="$HOME/.local/share/applications"
    if [[ -d "$app_dir" ]]; then
        update-desktop-database "$app_dir" 2>/dev/null || true
        if [[ "$comp" == "ide" ]]; then
            xdg-mime default antigravity-ide.desktop x-scheme-handler/antigravity-ide 2>/dev/null || true
        else
            xdg-mime default antigravity.desktop x-scheme-handler/antigravity 2>/dev/null || true
        fi
    fi

    log "${BOLD}$extract_dirname $ver${NC} successfully installed to $target_dir!"
}

# Auto update components (only updates if newer version is available or forced)
update_components() {
    local target="${1:-all}"
    log "Checking for updates for target: $target"
    
    local meta
    meta="$(fetch_releases_python latest all)"

    if [[ "$target" == "ide" || "$target" == "all" ]]; then
        local ide_latest ide_cur
        ide_latest="$(python3 -c 'import json, sys; d=json.loads(sys.argv[1]); print(d.get("ide",{}).get("version",""))' "$meta")"
        ide_cur="$(get_ide_version)"
        echo ""
        if [[ -z "$ide_latest" ]]; then
            warn "Could not fetch latest IDE version."
        elif [[ "$ide_cur" == "$ide_latest" ]]; then
            log "Antigravity IDE is already up to date ($ide_cur)."
        else
            info "Updating Antigravity IDE: $ide_cur -> $ide_latest"
            install_component ide "$ide_latest"
        fi
    fi

    if [[ "$target" == "hub" || "$target" == "all" ]]; then
        local hub_latest hub_cur
        hub_latest="$(python3 -c 'import json, sys; d=json.loads(sys.argv[1]); print(d.get("hub",{}).get("version",""))' "$meta")"
        hub_cur="$(get_hub_version)"
        echo ""
        if [[ -z "$hub_latest" ]]; then
            warn "Could not fetch latest Hub version."
        elif [[ "$hub_cur" == "$hub_latest" ]]; then
            log "Antigravity Hub is already up to date ($hub_cur)."
        else
            info "Updating Antigravity Hub: $hub_cur -> $hub_latest"
            install_component hub "$hub_latest"
        fi
    fi

    echo ""
    check_update
}

# List available scraped versions
list_versions() {
    local comp="${1:-all}"
    info "Available versions on https://antigravity.google/releases:"
    fetch_releases_python list "$comp" | python3 -c '
import json, sys
data = json.load(sys.stdin)
for k, v in data.items():
    print(f"  {k.upper()}:")
    for item in v[:10]:
        print(f"    - {item}")
'
}

# Main CLI dispatch
case "${1:-}" in
    check|status)
        check_update
        ;;
    list)
        list_versions "${2:-all}"
        ;;
    update)
        update_components "${2:-all}"
        ;;
    install)
        if [[ -z "${2:-}" ]]; then
            err "Usage: $0 install <ide|hub> [version]"
            err "Examples:"
            err "  $0 install ide"
            err "  $0 install hub 2.11.0"
            exit 1
        fi
        install_component "$2" "${3:-latest}"
        ;;
    *)
        echo -e "${BOLD}Antigravity Updater for Linux${NC}"
        echo ""
        echo "Usage:"
        echo "  $0 check                  Check installed vs latest release versions"
        echo "  $0 update [all|ide|hub]   Download & update outdated components"
        echo "  $0 install <ide|hub> [v]  Install specific or latest version"
        echo "  $0 list [all|ide|hub]     List available release versions"
        echo ""
        check_update
        ;;
esac
