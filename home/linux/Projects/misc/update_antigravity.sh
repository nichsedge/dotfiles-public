#!/usr/bin/env bash
set -euo pipefail

# Antigravity IDE Updater for Fedora Linux
# Downloads the latest tar.gz from Google CDN and extracts to ~/bin/

INSTALL_DIR="$HOME/bin"
APP_NAME="Antigravity IDE"
TAR_NAME="Antigravity IDE.tar.gz"
EXTRACT_DIR="$INSTALL_DIR/$APP_NAME"
SYMLINK="$INSTALL_DIR/antigravity-ide"
VERSION_FILE="$EXTRACT_DIR/version.txt"

# The download URL pattern from Google CDN
# Try the known path first
BASE_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable"
PLATFORM="linux-x64"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}→${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
err()  { echo -e "${RED}✗${NC} $1"; }

# Get current version from product.json ideVersion (real product version;
# package.json 'version' is just the Code-OSS base)
get_ide_version() {
    local prod="$EXTRACT_DIR/resources/app/product.json"
    if [[ -f "$prod" ]]; then
        python3 -c "import json; print(json.load(open('$prod')).get('ideVersion','?'))" 2>/dev/null || echo "?"
    elif [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "not_installed"
    fi
}

# Get version for Antigravity Desktop App (2.x)
get_antigravity_version() {
    local asar="$INSTALL_DIR/Antigravity-x64/resources/app.asar"
    if [[ -f "$asar" ]]; then
        python3 -c "
import os, re
path = os.path.expanduser('$asar')
if os.path.exists(path):
    with open(path, 'rb') as f:
        content = f.read()
        idx = content.find(b'\"name\": \"antigravity\"')
        if idx != -1:
            chunk = content[idx:idx+200]
            m = re.search(rb'\"version\"\s*:\s*\"([0-9\.]+)\"', chunk)
            if m:
                print(m.group(1).decode())
                exit(0)
print('unknown')
" 2>/dev/null || echo "?"
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

# Alias for backward compatibility
get_current_version() {
    get_ide_version
}

# Check for updates across all 3 Antigravity executables
# Fetch latest versions from the official download page
get_latest_versions() {
    curl -fsSL --connect-timeout 15 "https://antigravity.google/download?os=linux" 2>/dev/null | \
        grep -oE '(v[0-9]+\.[0-9]+\.[0-9]+)' | tr -d 'v' | head -4
}

check_update() {
    log "Checking Antigravity components installed on system:"
    echo ""
    printf "  %-22s %-12s %-12s %s\n" "Component" "Installed" "Latest" "Status"
    printf "  %-22s %-12s %-12s %s\n" "---------" "---------" "------" "------"

    local latest=()
    mapfile -t latest < <(get_latest_versions)
    local hub_latest="${latest[0]:-?}" cli_latest="${latest[1]:-?}" ide_latest="${latest[2]:-?}"

    # ahead-of-latest counts as up to date
    compare() { [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -1)" == "$1" ]] && echo -e "${GREEN}up to date${NC}" || echo -e "${YELLOW}update available${NC}"; }

    local hub_cur; hub_cur="$(get_antigravity_version)"
    local ide_cur; ide_cur="$(get_ide_version)"
    local cli_cur; cli_cur="$(get_agy_version)"

    printf "  %-22s %-12s %-12s %b\n" "antigravity (Hub)" "$hub_cur" "$hub_latest" "$(compare "$hub_cur" "$hub_latest")"
    printf "  %-22s %-12s %-12s %b\n" "antigravity-ide (IDE)" "$ide_cur" "$ide_latest" "$(compare "$ide_cur" "$ide_latest")"
    printf "  %-22s %-12s %-12s %b\n" "agy (CLI)" "$cli_cur" "$cli_latest" "$(compare "$cli_cur" "$cli_latest")"
    echo ""
}

# Download and install a specific version
install_version() {
    local version="$1"
    local tmpdir=$(mktemp -d)
    local tar_path="$tmpdir/$TAR_NAME"
    
    local url="$BASE_URL/$version/$PLATFORM/$TAR_NAME"
    
    log "Downloading Antigravity IDE $version..."
    log "URL: $url"
    
    if curl -#L --connect-timeout 30 -o "$tar_path" "$url" 2>&1; then
        log "Download complete ($(du -h "$tar_path" | cut -f1))"
    else
        err "Download failed — check version or URL"
        rm -rf "$tmpdir"
        exit 1
    fi
    
    # Backup old install
    if [[ -d "$EXTRACT_DIR" ]]; then
        local backup="$INSTALL_DIR/${APP_NAME}.bak.$(date +%Y%m%d-%H%M%S)"
        log "Backing up current install to: $backup"
        mv "$EXTRACT_DIR" "$backup"
    fi
    
    # Extract
    log "Extracting to $EXTRACT_DIR..."
    mkdir -p "$EXTRACT_DIR"
    tar -xzf "$tar_path" -C "$INSTALL_DIR"
    
    # Fix permissions
    chmod +x "$EXTRACT_DIR/antigravity-ide" 2>/dev/null || true
    
    # Create/update symlink
    [[ -L "$SYMLINK" ]] && rm "$SYMLINK"
    ln -s "$EXTRACT_DIR/bin/antigravity-ide" "$SYMLINK" 2>/dev/null || \
    ln -s "$EXTRACT_DIR/antigravity-ide" "$SYMLINK"
    
    # Save version
    echo "$version" > "$VERSION_FILE"
    
    # Cleanup
    rm -rf "$tmpdir"
    
    # Register protocol handler
    local desktop="$HOME/.local/share/applications/antigravity-ide.desktop"
    if [[ -f "$desktop" ]]; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
        xdg-mime default antigravity-ide.desktop x-scheme-handler/antigravity-ide 2>/dev/null || true
    fi
    
    log "Antigravity IDE $version installed!"
    get_current_version
}

# List what's available (try to find versions from download cache)
list_versions() {
    echo "Known download URL pattern:"
    echo "  $BASE_URL/<version>/$PLATFORM/$TAR_NAME"
    echo ""
    echo "Run with a version to install:"
    echo "  $0 install 2.0.1-4861014005645312"
}

case "${1:-}" in
    install)
        if [[ -z "${2:-}" ]]; then
            err "Usage: $0 install <version>"
            err "Example: $0 install 2.0.1-4861014005645312"
            exit 1
        fi
        install_version "$2"
        ;;
    check|status)
        check_update
        ;;
    *)
        echo "Antigravity Component Updater"
        echo ""
        echo "Usage:"
        echo "  $0 check              Show installed versions for all components"
        echo "  $0 install <version>  Download and install a specific IDE version"
        echo ""
        check_update
        ;;
esac