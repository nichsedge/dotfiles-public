#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
TERMINAL_APP="${TERMINAL_APP:-ghostty}"

usage() {
  cat <<'USAGE'
Usage: set-config.sh [--dry-run]

Applies standardized GNOME keyboard, window tiling, and multitasking preferences
aligned 1:1 with Niri, macOS, and standard PC muscle memory.
Override terminal with TERMINAL_APP=app.
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

echo "==> Configuring GNOME Keyboard & Repeat Rate"
run gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 30
run gsettings set org.gnome.desktop.peripherals.keyboard delay 250

echo "==> Configuring Window Management & Tiling (Super+Q, Super+F, Super+Left/Right)"
# Close window: Super+Q (Mac/Niri standard) and Alt+F4 (PC standard)
run gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q', '<Alt>F4']"
# Fullscreen: Super+F (Tiling WM standard) and F11
run gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super>f', 'F11']"
# Maximize / Unmaximize
run gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['<Super>Up', '<Alt>F10']"
run gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down', '<Alt>F5']"
run gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>h']"
# Snap Half Left & Right (Tiling Grid)
run gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Super>Left']"
run gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Super>Right']"

echo "==> Configuring Multitasking & Window Switching (Alt+Tab & Super+Tab)"
# Direct window switching across all workspaces (no app-grouping delay)
run gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab', '<Super>Tab']"
run gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab', '<Shift><Super>Tab']"
run gsettings set org.gnome.desktop.wm.keybindings switch-applications "['']"
run gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['']"
# Switch windows of current application (like macOS Cmd+` and Niri Alt+`)
run gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>Above_Tab', '<Alt>Above_Tab']"
run gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Super>Above_Tab', '<Shift><Alt>Above_Tab']"

echo "==> Configuring Workspaces (Super+Ctrl+Left/Right & Super+1..9)"
run gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Control><Alt>Left', '<Super>Page_Up']"
run gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Control><Alt>Right', '<Super>Page_Down']"
run gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Control><Shift><Alt>Left', '<Super><Shift>Page_Up']"
run gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Control><Shift><Alt>Right', '<Super><Shift>Page_Down']"
run gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"

# Unbind shell switch-to-application-1..9 to free Super+1..9 for direct workspace jumping
for i in {1..9}; do
  run gsettings set org.gnome.shell.keybindings "switch-to-application-$i" "['']"
  run gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" "['<Super>$i']"
  run gsettings set org.gnome.desktop.wm.keybindings "move-to-workspace-$i" "['<Super><Shift>$i']"
done

echo "==> Configuring Screenshots (3=Screen, 4=Area, 5=Window - Mac & Niri standard)"
run gsettings set org.gnome.shell.keybindings screenshot "['<Shift>Print', '<Super><Shift>3']"
run gsettings set org.gnome.shell.keybindings show-screenshot-ui "['Print', '<Super><Shift>4']"
run gsettings set org.gnome.shell.keybindings screenshot-window "['<Alt>Print', '<Super><Shift>5']"

echo "==> Setting Default Applications"
run gsettings set org.gnome.desktop.default-applications.terminal exec "$TERMINAL_APP"

if command -v xdg-mime >/dev/null 2>&1; then
  run xdg-mime default org.gnome.Nautilus.desktop inode/directory
fi

echo "==> Configuring Custom Keybindings (Super+Return, Super+T, Super+B, Super+E, Super+O, Super+Shift+T)"
CUSTOM_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

set_custom_key() {
  local id="$1"
  local name="$2"
  local cmd="$3"
  local binding="$4"

  if command -v dconf >/dev/null 2>&1; then
    run dconf write "${CUSTOM_PATH}/${id}/name" "'${name}'"
    run dconf write "${CUSTOM_PATH}/${id}/command" "'${cmd}'"
    run dconf write "${CUSTOM_PATH}/${id}/binding" "'${binding}'"
  fi
}

set_custom_key "open-terminal" "Terminal (Super+Return)" "$TERMINAL_APP" "<Super>Return"
set_custom_key "open-terminal-alt" "Terminal (Super+T)" "$TERMINAL_APP" "<Super>t"
set_custom_key "open-browser" "Browser" "google-chrome-stable" "<Super>b"
set_custom_key "open-nautilus" "Files" "nautilus --new-window" "<Super>e"
set_custom_key "toggle-overview" "Toggle Overview" "${HOME}/.local/bin/toggle-gnome-overview" "<Super>o"
set_custom_key "tailscale-menu" "Tailscale Menu" "${HOME}/.config/scripts/tailscale-menu.sh" "<Super><Shift>t"

if command -v dconf >/dev/null 2>&1; then
  run dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings \
    "['${CUSTOM_PATH}/open-terminal/', '${CUSTOM_PATH}/open-terminal-alt/', '${CUSTOM_PATH}/open-browser/', '${CUSTOM_PATH}/open-nautilus/', '${CUSTOM_PATH}/toggle-overview/', '${CUSTOM_PATH}/tailscale-menu/']"

  # Clipboard History extension toggle (Super+V)
  run dconf write /org/gnome/shell/extensions/clipboard-history/toggle-menu "['<Super>v']"
fi

echo "GNOME configuration successfully applied."
