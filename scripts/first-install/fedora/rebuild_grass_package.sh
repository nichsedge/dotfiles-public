#!/usr/bin/env bash
set -euo pipefail

# Set variables
DOWNLOADS_DIR="${HOME}/Downloads"
DEB_PACKAGE_PATH="${1:-"${DOWNLOADS_DIR}/Grass_5.7.1_amd64.deb"}"
EXTRACT_DIR="${DOWNLOADS_DIR}/extracted_folder"
NEW_PACKAGE_NAME="grass-blockchain-ai"
NEW_DEB_PATH="${DOWNLOADS_DIR}/${NEW_PACKAGE_NAME}.deb"

# Clean up previous extract if it exists
rm -rf "$EXTRACT_DIR"

# Extract the .deb package
if [[ ! -f "$DEB_PACKAGE_PATH" ]]; then
    echo "Error: deb package not found at $DEB_PACKAGE_PATH" >&2
    exit 1
fi
dpkg-deb -R "$DEB_PACKAGE_PATH" "$EXTRACT_DIR"

# Modify the control file to rename the package
CONTROL_FILE="$EXTRACT_DIR/DEBIAN/control"
if [[ -f "$CONTROL_FILE" ]]; then
    sed -i "s/^Package: .*/Package: ${NEW_PACKAGE_NAME}/" "$CONTROL_FILE"
else
    echo "Error: control file not found in $CONTROL_FILE" >&2
    exit 1
fi

# Rebuild the .deb package
dpkg-deb -b "$EXTRACT_DIR" "$NEW_DEB_PATH"

# Clean up previous extract if it exists
rm -rf "$EXTRACT_DIR"

echo "✅ Package rebuilt successfully: $NEW_DEB_PATH"

sudo apt install -f "$NEW_DEB_PATH"
