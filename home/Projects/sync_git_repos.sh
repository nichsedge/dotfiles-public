#!/bin/bash
# sync_git_repos.sh — pull latest changes in all project git repos
# Used by: sync-repos alias

PROJECTS_DIR="$HOME/Projects"

echo "=== Syncing all git repos under $PROJECTS_DIR ==="
echo ""

for dir in "$PROJECTS_DIR"/*/; do
    [ -d "$dir" ] || continue
    dir_name=$(basename "${dir%/}")

    if [ -d "$dir/.git" ]; then
        echo "→ $dir_name"
        git -C "$dir" pull --rebase --autostash -q 2>&1 | sed 's/^/  /'
    else
        echo "  $dir_name (not a git repo)"
    fi
done

echo ""
echo "Done."