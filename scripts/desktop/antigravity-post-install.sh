#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
BIN_DIR="${BIN_DIR:-$HOME/bin}"
DESKTOP_DIR="${DESKTOP_DIR:-$HOME/.local/share/applications}"
ANTIGRAVITY_IDE_DIR="${ANTIGRAVITY_IDE_DIR:-$BIN_DIR/Antigravity IDE}"
ANTIGRAVITY_APP_DIR="${ANTIGRAVITY_APP_DIR:-$BIN_DIR/Antigravity-x64}"

usage() {
  cat <<'USAGE'
Usage: antigravity-post-install.sh [--dry-run]

Creates desktop launchers and CLI symlinks for Antigravity apps.
Override paths with BIN_DIR, DESKTOP_DIR, ANTIGRAVITY_IDE_DIR, or ANTIGRAVITY_APP_DIR.
USAGE
}

run() {
  if [[ "$DRY_RUN" == true ]]; then
    printf 'DRY-RUN'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage; exit 1 ;;
  esac
done

run mkdir -p "$DESKTOP_DIR" "$BIN_DIR"

write_file() {
  local path="$1" content="$2"
  if [[ "$DRY_RUN" == true ]]; then
    echo "DRY-RUN write $path"
  else
    printf '%s\n' "$content" > "$path"
  fi
}

write_file "$DESKTOP_DIR/antigravity-ide.desktop" "[Desktop Entry]
Version=1.0
Type=Application
Name=Antigravity IDE
Exec=$ANTIGRAVITY_IDE_DIR/antigravity-ide %F
Icon=$ANTIGRAVITY_IDE_DIR/resources/app/resources/linux/code.png
Comment=Antigravity Integrated Development Environment
Categories=Development;IDE;
Terminal=false
StartupWMClass=antigravity-ide
StartupNotify=true"

write_file "$DESKTOP_DIR/antigravity.desktop" "[Desktop Entry]
Version=1.0
Type=Application
Name=Antigravity
Exec=$ANTIGRAVITY_APP_DIR/antigravity %F
Icon=antigravity
Comment=Antigravity Application
Categories=Development;
Terminal=false
StartupWMClass=antigravity
StartupNotify=true"

[[ -f "$ANTIGRAVITY_IDE_DIR/antigravity-ide" ]] && run chmod +x "$ANTIGRAVITY_IDE_DIR/antigravity-ide"
[[ -f "$ANTIGRAVITY_APP_DIR/antigravity" ]] && run chmod +x "$ANTIGRAVITY_APP_DIR/antigravity"
[[ -e "$ANTIGRAVITY_IDE_DIR/bin/antigravity-ide" ]] && run ln -sf "$ANTIGRAVITY_IDE_DIR/bin/antigravity-ide" "$BIN_DIR/antigravity-ide"
[[ -e "$ANTIGRAVITY_APP_DIR/antigravity" ]] && run ln -sf "$ANTIGRAVITY_APP_DIR/antigravity" "$BIN_DIR/antigravity"

command -v update-desktop-database >/dev/null 2>&1 && run update-desktop-database "$DESKTOP_DIR"
