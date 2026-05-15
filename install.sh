#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
BACKUP_DIR="${HOME_DIR}/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

FILES=(
  ".zshrc"
  ".zshenv"
  ".gitconfig"
  ".profile"
)

mkdir -p "${BACKUP_DIR}"

echo "Installing dotfiles from ${DOTFILES_DIR}/home"
for f in "${FILES[@]}"; do
  src="${DOTFILES_DIR}/home/${f}"
  dst="${HOME_DIR}/${f}"

  if [[ ! -f "${src}" ]]; then
    echo "Skip ${f}: source file missing"
    continue
  fi

  if [[ -L "${dst}" && "$(readlink -f "${dst}")" == "$(readlink -f "${src}")" ]]; then
    echo "OK   ${f} already linked"
    continue
  fi

  if [[ -e "${dst}" || -L "${dst}" ]]; then
    mv "${dst}" "${BACKUP_DIR}/${f}"
    echo "BACKUP ${dst} -> ${BACKUP_DIR}/${f}"
  fi

  ln -s "${src}" "${dst}"
  echo "LINK ${dst} -> ${src}"
done

echo "Done. Backup dir: ${BACKUP_DIR}"
echo "Tip: keep private machine-specific settings in ~/.zshrc.local"
