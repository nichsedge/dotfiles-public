#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"

FILES=(
  ".zshrc"
  ".zshenv"
  ".gitconfig"
  ".profile"
)

echo "Syncing files from ${HOME_DIR} -> ${DOTFILES_DIR}/home"
for f in "${FILES[@]}"; do
  src="${HOME_DIR}/${f}"
  dst="${DOTFILES_DIR}/home/${f}"

  if [[ -f "${src}" ]]; then
    cp "${src}" "${dst}"
    echo "SYNC ${f}"
  else
    echo "SKIP ${f}: missing in home"
  fi
done

echo "Done."
