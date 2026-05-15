#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_PACKAGES=true

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [--no-packages]

Options:
  --no-packages   Skip system package installation
EOF
}

for arg in "$@"; do
  case "$arg" in
    --no-packages) INSTALL_PACKAGES=false ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

detect_pm() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "apt"
    return
  fi
  if command -v pacman >/dev/null 2>&1; then
    echo "pacman"
    return
  fi
  if command -v dnf >/dev/null 2>&1; then
    echo "dnf"
    return
  fi
  if command -v brew >/dev/null 2>&1; then
    echo "brew"
    return
  fi
  echo "unknown"
}

install_core_packages() {
  local pm
  pm="$(detect_pm)"
  echo "Package manager: ${pm}"

  case "$pm" in
    apt)
      sudo apt-get update
      sudo apt-get install -y git curl zsh tmux ripgrep fzf fd-find bat eza
      ;;
    pacman)
      sudo pacman -Syu --noconfirm git curl zsh tmux ripgrep fzf fd bat eza
      ;;
    dnf)
      sudo dnf install -y git curl zsh tmux ripgrep fzf fd-find bat eza
      ;;
    brew)
      brew install git curl zsh tmux ripgrep fzf fd bat eza
      ;;
    *)
      echo "No supported package manager found. Skipping package install."
      ;;
  esac
}

install_oh_my_zsh_if_missing() {
  if [[ -d "${HOME}/.oh-my-zsh" ]]; then
    echo "oh-my-zsh already exists"
    return
  fi

  echo "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

ensure_zsh_default_hint() {
  if [[ "${SHELL:-}" != *"zsh" ]]; then
    echo "Default shell is not zsh. Run: chsh -s \"$(command -v zsh)\""
  fi
}

main() {
  echo "Bootstrapping from ${DOTFILES_DIR}"

  if [[ "$INSTALL_PACKAGES" == true ]]; then
    install_core_packages
  else
    echo "Skipping package installation (--no-packages)"
  fi

  install_oh_my_zsh_if_missing
  "${DOTFILES_DIR}/install.sh"
  ensure_zsh_default_hint

  echo "Bootstrap complete."
  echo "If needed, add machine-specific values to ~/.zshrc.local"
}

main "$@"
