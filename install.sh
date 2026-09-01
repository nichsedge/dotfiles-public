#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
BACKUP_DIR="${HOME_DIR}/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false
FORCE=false

# Detect platform: home/common/ is always linked; home/<platform>/ adds OS-specific files.
case "$(uname -s)" in
  Darwin) PLATFORM="darwin" ;;
  Linux)  PLATFORM="linux" ;;
  *)
    printf 'Unsupported platform: %s. Supported: Darwin, Linux.\n' "$(uname -s)"
    exit 1
    ;;
esac

FILES=(
  # Shared across Linux and macOS (paths relative to home/common/)
  ".zshrc"
  ".zshenv"
  ".gitconfig"
  ".profile"
  ".config/kitty/kitty.conf"
  ".config/starship.toml"
  ".config/zellij/config.kdl"
)

# Platform-specific files (paths relative to home/<platform>/)
PLATFORM_FILES=(
  "Projects/sync_git_repos.sh"
  ".local/share/applications/antigravity.desktop"
  ".local/share/applications/antigravity-ide.desktop"
  "Projects/misc/update_antigravity.sh"
  ".config/hypr/hyprland.conf"
  ".config/hypr/hyprlock.conf"
  ".config/hypr/hypridle.conf"
  ".config/hypr/hyprpaper.conf"
  ".config/hypr/scripts/brightness.sh"
  ".config/hypr/scripts/cheatsheet.sh"
  ".config/hypr/scripts/clipboard.sh"
  ".config/hypr/scripts/clipboard_fav.sh"
  ".config/hypr/scripts/powermenu.sh"
  ".config/hypr/scripts/screenshot.sh"
  ".config/hypr/scripts/volume.sh"
  ".config/hypr/scripts/wallpaper.sh"
  ".config/waybar/config"
  ".config/waybar/style.css"
  ".config/wofi/config"
  ".config/wofi/style.css"
)

if [[ "$PLATFORM" == "linux" ]]; then
  for f in "${PLATFORM_FILES[@]}"; do
    FILES+=("$f")
  done
fi

usage() {
  cat <<'USAGE'
Usage: ./install.sh [--dry-run] [--force]

Symlink public dotfiles from ./home into $HOME, backing up existing files first.

Options:
  --dry-run  Print actions without changing files
  --force    Replace an existing file/link even when it is not managed here
USAGE
}

log() { printf '%s\n' "$*"; }
run() {
  if [[ "$DRY_RUN" == true ]]; then
    printf 'DRY-RUN %q' "$1"
    shift
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --force) FORCE=true ;;
    -h|--help) usage; exit 0 ;;
    *) log "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

ensure_private_file() {
  local path="$1"
  local mode="$2"
  if [[ -e "$path" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      log "DRY-RUN chmod $mode $path"
    else
      chmod "$mode" "$path"
    fi
    return
  fi
  if [[ "$DRY_RUN" == true ]]; then
    log "DRY-RUN create $path mode $mode"
  else
    : > "$path"
    chmod "$mode" "$path"
  fi
}

mkdir_backup_if_needed=false

for f in "${FILES[@]}"; do
  # Resolve each file against common/ first, then the platform directory.
  if [[ -f "${DOTFILES_DIR}/home/common/${f}" ]]; then
    src="${DOTFILES_DIR}/home/common/${f}"
  elif [[ -f "${DOTFILES_DIR}/home/${PLATFORM}/${f}" ]]; then
    src="${DOTFILES_DIR}/home/${PLATFORM}/${f}"
  else
    src=""
  fi
  dst="${HOME_DIR}/${f}"

  if [[ -z "$src" ]]; then
    log "SKIP ${f}: source missing"
    continue
  fi

  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    log "OK   ${f} already linked"
    continue
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ "$FORCE" != true && ! -w "$dst" ]]; then
      log "STOP ${dst}: exists and is not writable; rerun with --force if intended"
      exit 1
    fi
    if [[ "$mkdir_backup_if_needed" == false ]]; then
      run mkdir -p "${BACKUP_DIR}/$(dirname "${f}")"
      mkdir_backup_if_needed=true
    fi
    run mkdir -p "${BACKUP_DIR}/$(dirname "${f}")"
    run mv "$dst" "${BACKUP_DIR}/${f}"
    log "BACKUP ${dst} -> ${BACKUP_DIR}/${f}"
  fi

  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
  log "LINK ${dst} -> ${src}"
done

ensure_private_file "${HOME_DIR}/.secrets" 0600
ensure_private_file "${HOME_DIR}/.zshrc.local" 0600
ensure_private_file "${HOME_DIR}/.profile.local" 0600

log "Install complete. Private local files are intentionally untracked."
if [[ "$mkdir_backup_if_needed" == true ]]; then
  log "Backup dir: ${BACKUP_DIR}"
fi

# Register protocol handler for Antigravity IDE (Linux only)
if [[ "$PLATFORM" == "linux" ]]; then
  if command -v update-desktop-database >/dev/null 2>&1; then
    run update-desktop-database "${HOME_DIR}/.local/share/applications"
  fi
  if command -v xdg-mime >/dev/null 2>&1; then
    run xdg-mime default antigravity-ide.desktop x-scheme-handler/antigravity-ide
  fi
fi
