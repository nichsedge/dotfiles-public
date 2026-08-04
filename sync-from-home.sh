#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
DRY_RUN=false

FILES=(
  ".zshrc"
  ".zshenv"
  ".gitconfig"
  ".profile"
  ".config/kitty/kitty.conf"
  ".config/starship.toml"
  "Projects/sync_git_repos.sh"
)

usage() {
  cat <<'USAGE'
Usage: ./sync-from-home.sh [--dry-run]

Copies managed dotfiles from $HOME into ./home. Review before committing;
this can reintroduce machine-specific values.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

for f in "${FILES[@]}"; do
  src="${HOME_DIR}/${f}"
  dst="${DOTFILES_DIR}/home/${f}"
  if [[ ! -f "$src" ]]; then
    echo "SKIP ${f}: missing in home"
    continue
  fi
  if [[ "$DRY_RUN" == true ]]; then
    echo "DRY-RUN cp ${src} ${dst}"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    chmod 0644 "$dst"
    echo "SYNC ${f}"
  fi
done

echo "Run ./scripts/tools/secret-scan.sh before committing."
