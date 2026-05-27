#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
RELOAD=true
EXTENSION_UUID="dash-to-dock@micxgx.gmail.com"
EXTENSION_DIR="${EXTENSION_DIR:-$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID}"
SOURCE_SVG="${SOURCE_SVG:-$HOME/Projects/misc/MacTahoe-gtk-theme/src/assets/gnome-shell/common-assets/view-app-grid.svg}"
TARGET_SVG="$EXTENSION_DIR/media/view-app-grid.svg"
STYLESHEET="$EXTENSION_DIR/stylesheet.css"
BLOCK_BEGIN="/* BEGIN dotfiles-public MacTahoe show-apps icon override */"
BLOCK_END="/* END dotfiles-public MacTahoe show-apps icon override */"
LEGACY_BLOCK_BEGIN="/* MacTahoe show-apps icon override */"

usage() {
  cat <<'USAGE'
Usage: apply-dash-to-dock-grid-icon.sh [--dry-run] [--no-reload]

Reapplies the MacTahoe view-app-grid.svg icon override to Dash to Dock.

Override paths with:
  SOURCE_SVG=/path/to/view-app-grid.svg
  EXTENSION_DIR=/path/to/dash-to-dock@micxgx.gmail.com
USAGE
}

log() { printf '%s\n' "$*"; }

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
    --no-reload) RELOAD=false ;;
    -h|--help) usage; exit 0 ;;
    *) log "Unknown option: $arg" >&2; usage; exit 1 ;;
  esac
done

if [[ ! -d "$EXTENSION_DIR" ]]; then
  log "Missing Dash to Dock extension directory: $EXTENSION_DIR" >&2
  exit 1
fi

if [[ ! -f "$STYLESHEET" ]]; then
  log "Missing Dash to Dock stylesheet: $STYLESHEET" >&2
  exit 1
fi

if [[ ! -f "$SOURCE_SVG" ]]; then
  log "Missing source SVG: $SOURCE_SVG" >&2
  exit 1
fi

css_block() {
  cat <<EOF
$BLOCK_BEGIN
.dash-item-container .show-apps .show-apps-icon {
  color: transparent !important;
  background-image: url("./media/view-app-grid.svg");
  background-size: contain; }

.dash-item-container .show-apps .overview-icon,
.dash-item-container .show-apps:hover .overview-icon,
.dash-item-container .show-apps:active .overview-icon,
.dash-item-container .show-apps:checked .overview-icon,
.dash-item-container .show-apps:focus .overview-icon {
  color: transparent !important; }
$BLOCK_END
EOF
}

write_stylesheet() {
  local tmp

  if grep -Fxq "$BLOCK_BEGIN" "$STYLESHEET" && ! grep -Fxq "$LEGACY_BLOCK_BEGIN" "$STYLESHEET"; then
    log "OK stylesheet already contains the override"
    return
  fi

  tmp="$(mktemp)"

  awk -v begin="$BLOCK_BEGIN" -v end="$BLOCK_END" -v legacy="$LEGACY_BLOCK_BEGIN" '
    $0 == begin { skip_marked = 1; next }
    $0 == end { skip_marked = 0; next }
    skip_marked == 1 { next }
    $0 == legacy { skip_legacy = 1; legacy_close_count = 0; next }
    skip_legacy == 1 {
      if ($0 ~ /}/) { legacy_close_count++ }
      if (legacy_close_count >= 2) { skip_legacy = 0 }
      next
    }
    skip_legacy != 1 { print }
  ' "$STYLESHEET" > "$tmp"

  {
    printf '\n'
    css_block
  } >> "$tmp"

  if cmp -s "$tmp" "$STYLESHEET"; then
    rm -f "$tmp"
    log "OK stylesheet already contains the override"
    return
  fi

  run cp "$STYLESHEET" "$STYLESHEET.bak-dotfiles-$(date +%Y%m%d-%H%M%S)"

  if [[ "$DRY_RUN" == true ]]; then
    log "DRY-RUN write $STYLESHEET"
    rm -f "$tmp"
  else
    mv "$tmp" "$STYLESHEET"
  fi
}

run mkdir -p "$EXTENSION_DIR/media"
run cp "$SOURCE_SVG" "$TARGET_SVG"
write_stylesheet

if [[ "$RELOAD" == true ]] && command -v gnome-extensions >/dev/null 2>&1; then
  if gnome-extensions info "$EXTENSION_UUID" >/dev/null 2>&1; then
    run gnome-extensions disable "$EXTENSION_UUID"
    run sleep 1
    run gnome-extensions enable "$EXTENSION_UUID"
  else
    log "SKIP reload: extension is not registered with gnome-extensions"
  fi
fi

log "Applied Dash to Dock show-apps icon override."
