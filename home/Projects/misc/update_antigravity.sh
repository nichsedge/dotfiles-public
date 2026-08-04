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

# Get current version from package.json
get_current_version() {
    local pkg="$EXTRACT_DIR/resources/app/package.json"
    if [[ -f "$pkg" ]]; then
        python3 -c "import json; print(json.load(open('$pkg')).get('version','?'))" 2>/dev/null || echo "?"
    else
        echo "not_installed"
    fi
}

# Check for updates by trying common version paths
check_update() {
    local current=$(get_current_version)
    log "Current version: $current"
    
    # Try to discover the latest version by checking the CDN
    # The CDN path includes a version string like 2.0.1-4861014005645312
    # Without directory listing, we need to know the version to check
    warn "Cannot auto-detect latest version from CDN (no directory listing)"
    warn "Check https://antigravity.google.com for latest version info"
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
        echo ""
        echo "Install location: $EXTRACT_DIR"
        echo "Symlink: $SYMLINK → $(readlink -f "$SYMLINK" 2>/dev/null || echo 'broken')"
        echo "Version: $(get_current_version)"
        ;;
    *)
        echo "Antigravity IDE Updater"
        echo ""
        echo "Usage:"
        echo "  $0 check              Show current version"
        echo "  $0 install <version>  Download and install a specific version"
        echo "  $0 install latest     Try to install latest known version"
        echo ""
        echo "Current: $(get_current_version)"
        ;;
esac