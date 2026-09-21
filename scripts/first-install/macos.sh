#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
SKIP_CASKS=true

usage() {
  cat <<'USAGE'
Usage: macos.sh [--dry-run] [--with-casks]

Safe, zero-sudo macOS bootstrap script for corporate / managed laptops.
Installs CLI tools using Homebrew (if healthy) or standalone user binaries (~/.local/bin).

Options:
  --dry-run     Print actions without installing
  --with-casks  Attempt to install GUI casks (Ghostty, iTerm2); requires writable /Applications
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
    --with-casks) SKIP_CASKS=false; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

echo "🍎 macOS Bootstrap (Zero-Sudo Mode)"

mkdir -p "$HOME/.local/bin"

# 1. Test Homebrew Health & Permissions
BREW_USABLE=false
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
  if [[ -w "$BREW_PREFIX" && -w "$BREW_PREFIX/bin" ]]; then
    BREW_USABLE=true
    echo "✓ Homebrew found and user-writable ($BREW_PREFIX)"
  else
    echo "⚠ Homebrew found at $BREW_PREFIX, but user lacks write permissions (permission corruption)."
    echo "  Falling back to isolated ~/.local/bin installations to avoid sudo."
  fi
else
  echo "ℹ Homebrew not detected in PATH."
fi

if [[ "$BREW_USABLE" == true ]]; then
  echo "📦 Installing CLI tools via Homebrew (pure formulas, zero sudo)..."
  run brew install starship zoxide eza bat fd ripgrep fzf gh git-delta direnv

  if [[ "$SKIP_CASKS" == false ]]; then
    echo "🖥️ Installing GUI apps into ~/Applications to avoid /Applications permission prompts..."
    run brew install --cask --appdir="$HOME/Applications" ghostty || true
  fi
else
  echo "🚀 Installing standalone user binaries directly to ~/.local/bin (100% user-space, zero sudo)..."

  # Starship
  if ! command -v starship >/dev/null 2>&1; then
    echo "  → Installing starship..."
    run sh -c 'curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$HOME/.local/bin" -y'
  fi

  # Zoxide
  if ! command -v zoxide >/dev/null 2>&1; then
    echo "  → Installing zoxide..."
    run sh -c 'curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | BIN_DIR="$HOME/.local/bin" sh'
  fi

  # FZF
  if [[ ! -d "$HOME/.fzf" ]]; then
    echo "  → Installing fzf..."
    run git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    run "$HOME/.fzf/install" --bin --no-update-rc
    run ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"
  fi

  # UV (Python package manager)
  if ! command -v uv >/dev/null 2>&1; then
    echo "  → Installing uv..."
    run sh -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
  fi

  # Bun (JS/TS runtime)
  if ! command -v bun >/dev/null 2>&1; then
    echo "  → Installing bun..."
    run sh -c 'curl -fsSL https://bun.sh/install | bash'
  fi
fi

echo "✅ macOS CLI environment is ready (Zero sudo needed)!"
