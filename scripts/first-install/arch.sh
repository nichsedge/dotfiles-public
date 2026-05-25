#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
INSTALL_YAY=true

usage() {
  cat <<'USAGE'
Usage: arch.sh [--dry-run] [--no-yay]

Secondary Arch workstation bootstrap. Installs base tooling and optional yay/AUR packages.
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
    --no-yay) INSTALL_YAY=false; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if ! command -v pacman >/dev/null 2>&1; then
  if [[ "$DRY_RUN" == true ]]; then
    echo "DRY-RUN pacman not found on this host; showing planned Arch commands anyway."
  else
    echo "pacman not found." >&2
    exit 1
  fi
fi

run sudo pacman -Syu --needed --noconfirm \
  base-devel git curl wget zsh flatpak docker dbeaver firefox \
  gnome-shell-extensions gnome-browser-connector gnome-tweaks \
  extension-manager dconf-editor htop btop ripgrep fzf fd bat eza \
  noto-fonts noto-fonts-cjk noto-fonts-emoji vlc pandoc gcc-fortran openblas

if [[ "$INSTALL_YAY" == true && ! -x "$(command -v yay || true)" ]]; then
  tmpdir="$(mktemp -d)"
  run git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  run sh -c "cd '$tmpdir/yay' && makepkg -si --noconfirm"
  run rm -rf "$tmpdir"
fi

if command -v yay >/dev/null 2>&1; then
  run yay -S --needed --noconfirm google-chrome visual-studio-code-bin proton-vpn-gtk-app
fi

echo "Arch bootstrap complete. Playwright/system-library workarounds should be handled per project."
