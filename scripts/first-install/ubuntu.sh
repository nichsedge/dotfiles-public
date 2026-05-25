#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
INSTALL_DOCKER=true
INSTALL_FLATPAK=true

usage() {
  cat <<'USAGE'
Usage: ubuntu.sh [--dry-run] [--no-docker] [--no-flatpak]

Secondary Ubuntu workstation bootstrap. Review before use on a fresh release.
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
    --no-docker) INSTALL_DOCKER=false; shift ;;
    --no-flatpak) INSTALL_FLATPAK=false; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

[[ "$(id -u)" -ne 0 ]] || { echo "Run as a normal user, not root." >&2; exit 1; }
if ! command -v apt-get >/dev/null 2>&1; then
  if [[ "$DRY_RUN" == true ]]; then
    echo "DRY-RUN apt-get not found on this host; showing planned Ubuntu commands anyway."
  else
    echo "apt-get not found." >&2
    exit 1
  fi
fi

run sudo apt-get update
run sudo apt-get upgrade -y
run sudo apt-get install -y \
  adb bat build-essential ca-certificates cmake curl default-jdk default-jre \
  ffmpeg firefox flatpak fzf gh git gnome-shell-extension-manager \
  gnome-software-plugin-flatpak gnome-tweaks htop jq kitty libffi-dev \
  libfuse2 python3-dev ripgrep scrcpy software-properties-common unzip vlc wget zsh

if [[ "$INSTALL_FLATPAK" == true ]]; then
  run sudo apt-get install -y flatpak gnome-software-plugin-flatpak
  run flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

if [[ "$INSTALL_DOCKER" == true ]]; then
  run sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
  run sudo install -m 0755 -d /etc/apt/keyrings
  run sh -c 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg'
  run sudo chmod a+r /etc/apt/keyrings/docker.gpg
  run sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null'
  run sudo apt-get update
  run sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  run sudo usermod -aG docker "$USER"
fi

echo "Ubuntu bootstrap complete. Reboot or log out/in if shell or Docker group membership changed."
