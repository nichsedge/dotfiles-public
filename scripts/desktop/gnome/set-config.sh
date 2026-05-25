#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
TERMINAL_APP="${TERMINAL_APP:-kitty}"

usage() {
  cat <<'USAGE'
Usage: set-config.sh [--dry-run]

Applies portable GNOME keyboard/window preferences. Override terminal with TERMINAL_APP=app.
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
    *) echo "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

command -v gsettings >/dev/null 2>&1 || { echo "gsettings not found" >&2; exit 1; }

run gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 30
run gsettings set org.gnome.desktop.peripherals.keyboard delay 250
run gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['']"
run gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['']"
run gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
run gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
run gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
run gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
run gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
run gsettings set org.gnome.desktop.default-applications.terminal exec "$TERMINAL_APP"

if command -v xdg-mime >/dev/null 2>&1; then
  run xdg-mime default org.gnome.Nautilus.desktop inode/directory
fi

if command -v dconf >/dev/null 2>&1; then
  run dconf write /org/gnome/shell/extensions/clipboard-history/toggle-menu "['<Super>v']"
fi
