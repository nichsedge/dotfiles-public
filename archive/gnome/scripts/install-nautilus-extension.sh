#!/usr/bin/env bash
set -euo pipefail

name="${1:-}"
[[ -n "$name" ]] || { echo "Usage: install-nautilus-extension.sh code|antigravity" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_DIR="$HOME/.local/share/nautilus-python/extensions"

install_python_nautilus() {
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y nautilus-python
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y python3-nautilus
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm python-nautilus
  fi
}

install_python_nautilus
mkdir -p "$EXT_DIR"

case "$name" in
  code) cp "$SCRIPT_DIR/nautilus-code/code-nautilus.py" "$EXT_DIR/code-nautilus.py" ;;
  antigravity) cp "$SCRIPT_DIR/nautilus-antigravity/antigravity-nautilus.py" "$EXT_DIR/antigravity-nautilus.py" ;;
  *) echo "Unknown extension: $name" >&2; exit 1 ;;
esac

nautilus -q 2>/dev/null || true
echo "Installed Nautilus extension: $name"
