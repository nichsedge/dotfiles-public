#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="fedora-gnome"
INSTALL_PACKAGES=true
DRY_RUN=false

usage() {
  cat <<'USAGE'
Usage: ./bootstrap.sh [--profile fedora-gnome|minimal|mobile] [--no-packages] [--dry-run]

Bootstraps a new machine using this public dotfiles repo.

Options:
  --profile NAME  Install profile: fedora-gnome, minimal, or mobile (PRoot/Debian/headless). Default: fedora-gnome
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

get_sudo() {
  if [[ "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
    echo "sudo"
  else
    echo ""
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
  run sudo dnf copr enable -y scottames/ghostty
  if [[ -f "$DOTFILES_DIR/packages/fedora-gnome.txt" ]]; then
    log "Installing Fedora packages from packages/fedora-gnome.txt"
    run sudo dnf install -y $(grep -v '^#' "$DOTFILES_DIR/packages/fedora-gnome.txt" | grep -v '^$' | tr '\n' ' ')
  else
    run sudo dnf install -y git curl wget zsh tmux ripgrep fzf fd-find bat eza starship zoxide lazygit git-delta direnv htop btop fastfetch tldr glow jq unzip util-linux-user gcc gcc-c++ make cmake python3-devel libffi-devel gh ghostty gnome-tweaks gnome-extensions-app dconf-editor jetbrainsmono-nerd-fonts flatpak fuse fuse-libs ntfs-3g vlc firefox
  fi
  run flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  if [[ -f "$DOTFILES_DIR/packages/flatpaks.txt" ]]; then
    log "Installing flatpaks from packages/flatpaks.txt"
    while IFS= read -r appid; do
      [[ -z "$appid" || "$appid" == \#* ]] && continue
      run flatpak install -y flathub "$appid"
    done < "$DOTFILES_DIR/packages/flatpaks.txt"
  fi
}

install_minimal_packages() {
  local sudo_cmd; sudo_cmd="$(get_sudo)"
  if command -v dnf >/dev/null 2>&1; then
    run $sudo_cmd dnf install -y git curl zsh ripgrep fzf fd-find bat eza gh starship zoxide lazygit git-delta direnv
  elif command -v apt-get >/dev/null 2>&1; then
    run $sudo_cmd apt-get update
    run $sudo_cmd apt-get install -y git curl zsh ripgrep fzf fd-find bat gh
  elif command -v pacman >/dev/null 2>&1; then
    run $sudo_cmd pacman -Syu --noconfirm git curl zsh ripgrep fzf fd bat github-cli
  else
    log "No supported package manager found; skipping package install."
  fi
}

install_mobile_packages() {
  local sudo_cmd; sudo_cmd="$(get_sudo)"
  if command -v apt-get >/dev/null 2>&1; then
    run $sudo_cmd apt-get update
    run $sudo_cmd apt-get install -y git curl zsh ripgrep fzf unzip ca-certificates locales ncurses-term
    if command -v locale-gen >/dev/null 2>&1; then
      run sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen || true
      run locale-gen || true
      run update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 || true
    fi
  elif command -v dnf >/dev/null 2>&1; then
    run $sudo_cmd dnf install -y git curl zsh ripgrep fzf unzip glibc-langpack-en ncurses-term
  elif command -v pacman >/dev/null 2>&1; then
    run $sudo_cmd pacman -Syu --noconfirm git curl zsh ripgrep fzf unzip
  else
    log "No supported package manager found; skipping mobile packages."
  fi

  # Ensure Starship prompt is present for fast, clean prompt
  if ! command -v starship >/dev/null 2>&1; then
    log "Installing Starship prompt..."
    run sh -c 'curl -sS https://starship.rs/install.sh | sh -s -- -y' || true
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
  # shellcheck disable=SC1091
  [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env" || true
  [[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env" || true
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.bun/bin:$PATH"

  if ! command -v bun >/dev/null 2>&1; then
    run sh -c 'curl -fsSL https://bun.sh/install | bash'
  fi
  if ! command -v agy >/dev/null 2>&1; then
    log "Installing Antigravity CLI (agy)..."
    run sh -c 'curl -fsSL https://antigravity.google/cli/install.sh | bash' || true
  fi
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.bun/bin:$PATH"

  # Mobile profile skips heavy compiler toolchains and secondary global manifests
  if [[ "$PROFILE" == "mobile" ]]; then
    log "Mobile profile: skipping rustup and secondary package manifests (minimalist AI stack)."
    return
  fi

  if ! command -v rustup >/dev/null 2>&1; then
    run sh -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
  fi
  # reinstall user tools from manifests (lean, idempotent)
  if [[ -f "$DOTFILES_DIR/packages/uv-tools.txt" ]] && command -v uv >/dev/null 2>&1; then
    log "Reinstalling uv tools from packages/uv-tools.txt"
    while IFS= read -r tool; do
      [[ -z "$tool" || "$tool" == \#* ]] && continue
      run uv tool install "$tool" || true
    done < "$DOTFILES_DIR/packages/uv-tools.txt"
  fi
  if [[ -f "$DOTFILES_DIR/packages/bun-global.json" ]] && command -v bun >/dev/null 2>&1; then
    log "Reinstalling bun globals from packages/bun-global.json"
    run sh -c 'cd "$DOTFILES_DIR" && bun install --cwd "$HOME/.bun/install/global" 2>/dev/null || (cat packages/bun-global.json | python3 -c "import json; j=json.load(open(\"packages/bun-global.json\")); print(chr(10).join([f\"{k}@{v}\" for k,v in j.get(\"dependencies\",{}).items()]))" | xargs -r bun add -g)' || true
  fi
  if [[ -f "$DOTFILES_DIR/packages/npm-global.txt" ]] && command -v npm >/dev/null 2>&1; then
    log "Reinstalling npm globals from packages/npm-global.txt"
    while IFS= read -r pkg; do
      [[ -z "$pkg" || "$pkg" == \#* ]] && continue
      run npm install -g "$pkg" || true
    done < "$DOTFILES_DIR/packages/npm-global.txt"
  fi
}

ensure_zsh_default_hint() {
  if [[ "$PROFILE" == "mobile" ]]; then
    if [[ -f "$HOME/.bashrc" ]] && ! grep -q "exec zsh" "$HOME/.bashrc"; then
      log "Adding automatic Zsh switch to $HOME/.bashrc for PRoot compatibility"
      if [[ "$DRY_RUN" == true ]]; then
        log "DRY-RUN append auto-switch to zsh in $HOME/.bashrc"
      else
        cat << 'EOF' >> "$HOME/.bashrc"

# Auto switch to zsh in PRoot
if [ -t 1 ] && [ -n "${PS1:-}" ] && [ -x "$(command -v zsh 2>/dev/null)" ]; then
  export SHELL="$(command -v zsh)"
  exec zsh
fi
EOF
      fi
    fi
    return
  fi

  if [[ "${SHELL:-}" != *zsh ]]; then
    log "Default shell is not zsh. Run after bootstrap if desired: chsh -s \"$(command -v zsh || echo /usr/bin/zsh)\""
  fi
}

case "$PROFILE" in
  fedora-gnome|minimal|mobile) ;;
  *) log "Unsupported profile: $PROFILE"; usage; exit 1 ;;
esac

log "Bootstrapping ${PROFILE} from ${DOTFILES_DIR}"

if [[ "$INSTALL_PACKAGES" == true ]]; then
  case "$PROFILE" in
    fedora-gnome) install_fedora_packages ;;
    minimal) install_minimal_packages ;;
    mobile) install_mobile_packages ;;
  esac
else
  log "Skipping package installation (--no-packages)"
fi

install_oh_my_zsh_if_missing
install_zsh_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
install_zsh_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
install_external_tools

install_flags=()
[[ "$DRY_RUN" == true ]] && install_flags+=(--dry-run)
[[ "$PROFILE" == "mobile" || "$PROFILE" == "minimal" ]] && install_flags+=(--headless)
"${DOTFILES_DIR}/install.sh" "${install_flags[@]}"
ensure_zsh_default_hint

log "Bootstrap complete. Private setup can be layered from ~/Projects/creds later."
