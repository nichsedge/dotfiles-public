#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
DRY_RUN=false

FILES=(
  ".zshrc"
  ".zshenv"
  ".gitconfig"
  ".profile"
  ".config/ghostty/config"
  ".config/ghostty/themes/dankcolors"
  ".config/starship.toml"
  ".config/zellij/config.kdl"
  "Projects/sync_git_repos.sh"
  ".local/share/applications/antigravity.desktop"
  ".local/share/applications/antigravity-ide.desktop"
  ".local/share/applications/cosmic-clipboard.desktop"
  ".local/share/applications/dev.nichsedge.CosmicPanelClipboardButton.desktop"
  ".local/share/applications/google-chrome.desktop"
  ".local/bin/update-antigravity"
  ".local/bin/cosmic-clipboard"
  ".local/bin/google-chrome-stable"
  ".config/systemd/user/cliphist.service"
  ".config/kcminputrc"
  ".config/kwinrc"
  ".config/kglobalshortcutsrc"
  ".config/kdeglobals"
  ".config/krunnerrc"
  ".config/plasmashellrc"
  ".config/environment.d/cursor.conf"
  ".local/share/applications/hotkey-cheatsheet.desktop"
  ".local/share/applications/tailscale-menu.desktop"
  ".config/scripts/tailscale-menu.sh"
  ".config/scripts/tailscale-toggle.sh"
  ".config/scripts/hotkey-cheatsheet.py"
  ".local/share/icons/default/index.theme"
  ".local/share/flatpak/overrides/global"
  ".local/share/flatpak/overrides/org.videolan.VLC"
)

usage() {
  cat <<'USAGE'
Usage: ./sync-from-home.sh [--dry-run]

Copies managed dotfiles from $HOME into ./home. Review before committing;
this can reintroduce machine-specific values.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

# Detect platform so synced files land in the right directory.
case "$(uname -s)" in
  Darwin) PLATFORM="darwin" ;;
  Linux)  PLATFORM="linux" ;;
  *) echo "Unsupported platform: $(uname -s)"; exit 1 ;;
esac

# Include COSMIC desktop configs on Linux if present (excluding personal wallpaper & file paths)
if [[ "$PLATFORM" == "linux" && -d "${HOME_DIR}/.config/cosmic" ]]; then
  while IFS= read -r file; do
    rel="${file#${HOME_DIR}/}"
    FILES+=("$rel")
  done < <(find "${HOME_DIR}/.config/cosmic" -type f ! -path "*/com.system76.CosmicBackground/*" ! -path "*/com.system76.CosmicSettings.Wallpaper/*" ! -path "*/com.system76.CosmicFiles/*" 2>/dev/null || true)
fi

for f in "${FILES[@]}"; do
  src="${HOME_DIR}/${f}"
  if [[ -f "${DOTFILES_DIR}/home/common/${f}" ]]; then
    dst="${DOTFILES_DIR}/home/common/${f}"
  else
    dst="${DOTFILES_DIR}/home/${PLATFORM}/${f}"
  fi
  if [[ ! -f "$src" ]]; then
    echo "SKIP ${f}: missing in home"
    continue
  fi
  if [[ -f "$dst" && "$src" -ef "$dst" ]]; then
    echo "SKIP ${f}: already symlinked"
    continue
  fi
  if [[ "$DRY_RUN" == true ]]; then
    echo "DRY-RUN cp ${src} ${dst}"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    chmod 0644 "$dst"
    echo "SYNC ${f}"
  fi
done

echo "Run ./scripts/tools/secret-scan.sh before committing."
