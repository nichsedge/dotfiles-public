#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="fedora-gnome"
INSTALL_PACKAGES=true
DRY_RUN=false

usage() {
  cat <<'USAGE'
Usage: ./bootstrap.sh [--profile fedora-gnome|minimal] [--no-packages] [--dry-run]

Bootstraps a new machine using this public dotfiles repo.

Options:
  --profile NAME  Install profile. Default: fedora-gnome
  --no-packages   Skip package and external tool installation
  --dry-run       Print actions without changing files
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="${2:-}"; shift 2 ;;
    --profile=*) PROFILE="${1#*=}"; shift ;;
    --no-packages) INSTALL_PACKAGES=false; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) log "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "$PROFILE" ]]; then
  log "Missing profile value"
  usage
  exit 1
fi

install_fedora_packages() {
  if ! command -v dnf >/dev/null 2>&1; then
    log "DNF not found; skipping Fedora package install."
    return
  fi

  run sudo dnf upgrade -y
  run sudo dnf install -y \
    git curl wget zsh tmux ripgrep fzf fd-find bat eza starship zoxide lazygit git-delta direnv \
    htop btop fastfetch tldr glow jq unzip util-linux-user \
    gcc gcc-c++ make cmake python3-devel libffi-devel \
    gh kitty gnome-tweaks gnome-extensions-app dconf-editor \
    jetbrainsmono-nerd-fonts flatpak fuse fuse-libs ntfs-3g vlc firefox

  run flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

install_minimal_packages() {
  if command -v dnf >/dev/null 2>&1; then
    run sudo dnf install -y git curl zsh ripgrep fzf fd-find bat eza gh starship zoxide lazygit git-delta direnv
  elif command -v apt-get >/dev/null 2>&1; then
    run sudo apt-get update
    run sudo apt-get install -y git curl zsh ripgrep fzf fd-find bat gh
  elif command -v pacman >/dev/null 2>&1; then
    run sudo pacman -Syu --noconfirm git curl zsh ripgrep fzf fd bat github-cli
  else
    log "No supported package manager found; skipping package install."
  fi
}

install_oh_my_zsh_if_missing() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "oh-my-zsh already exists"
    return
  fi
  run sh -c 'RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
}

install_zsh_plugin() {
  local name="$1"
  local repo="$2"
  local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/${name}"
  [[ -d "$dest" ]] && { log "${name} already exists"; return; }
  run git clone --depth 1 "$repo" "$dest"
}

install_external_tools() {
  if ! command -v uv >/dev/null 2>&1; then
    run sh -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
  fi
  if ! command -v rustup >/dev/null 2>&1; then
    run sh -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
  fi
  if ! command -v bun >/dev/null 2>&1; then
    run sh -c 'curl -fsSL https://bun.sh/install | bash'
  fi
}

ensure_zsh_default_hint() {
  if [[ "${SHELL:-}" != *zsh ]]; then
    log "Default shell is not zsh. Run after bootstrap if desired: chsh -s \"$(command -v zsh || echo /usr/bin/zsh)\""
  fi
}

case "$PROFILE" in
  fedora-gnome|minimal) ;;
  *) log "Unsupported profile: $PROFILE"; usage; exit 1 ;;
esac

log "Bootstrapping ${PROFILE} from ${DOTFILES_DIR}"

if [[ "$INSTALL_PACKAGES" == true ]]; then
  case "$PROFILE" in
    fedora-gnome) install_fedora_packages ;;
    minimal) install_minimal_packages ;;
  esac
else
  log "Skipping package installation (--no-packages)"
fi

install_oh_my_zsh_if_missing
install_zsh_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
install_zsh_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
install_external_tools
"${DOTFILES_DIR}/install.sh" ${DRY_RUN:+--dry-run}
ensure_zsh_default_hint

log "Bootstrap complete. Private setup can be layered from ~/Projects/creds later."
