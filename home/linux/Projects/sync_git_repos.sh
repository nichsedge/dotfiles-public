#!/bin/bash
# sync_git_repos.sh — inspect and safely pull latest changes across all project git repos
exec python3 "$HOME/Projects/_scheduled_jobs/repos_status.py" --pull "$@"