#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
INSTALL_AI_CLIS=true
INSTALL_TAILSCALE=true

usage() {
  cat <<'USAGE'
Usage: install-dev-tools.sh [--dry-run] [--ai-clis] [--tailscale]

Installs common user-level development tools: oh-my-zsh plugins, uv, Rust, and Bun.
Optional flags install npm AI CLIs and Tailscale.
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --ai-clis) INSTALL_AI_CLIS=true; shift ;;
    --tailscale) INSTALL_TAILSCALE=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

install_plugin() {
  local name="$1"
  local repo="$2"
  local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"
  [[ -d "$dest" ]] && { echo "$name already installed"; return; }
  run git clone --depth 1 "$repo" "$dest"
}

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  run sh -c 'RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
fi

install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git

command -v uv >/dev/null 2>&1 || run sh -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
command -v rustup >/dev/null 2>&1 || run sh -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
command -v bun >/dev/null 2>&1 || run sh -c 'curl -fsSL https://bun.sh/install | bash'

if [[ "$INSTALL_AI_CLIS" == true ]]; then
  command -v npm >/dev/null 2>&1 || { echo "npm not found; skipping AI CLIs" >&2; exit 1; }
  run npm install -g @openai/codex @google/gemini-cli @anthropic-ai/claude-code
fi

if [[ "$INSTALL_TAILSCALE" == true ]]; then
  command -v tailscale >/dev/null 2>&1 || run sh -c 'curl -fsSL https://tailscale.com/install.sh | sh'
  run sudo tailscale set --operator="$USER"
fi
