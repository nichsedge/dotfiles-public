#!/bin/bash
# sync_git_repos.sh — inspect and safely pull latest changes across all project git repos
exec repos-status --pull "$@"