#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

status=0

patterns=(
  'BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY'
  '"private_key"[[:space:]]*:'
  '"client_secret"[[:space:]]*:'
  '"refresh_token"[[:space:]]*:'
  '"access_token"[[:space:]]*:'
  'AIza[0-9A-Za-z_-]{20,}'
  'ghp_[0-9A-Za-z_]{20,}'
  'github_pat_[0-9A-Za-z_]{20,}'
)

for pattern in "${patterns[@]}"; do
  if rg -n --hidden --glob '!.git/**' --glob '!examples/**' -e "$pattern" .; then
    status=1
  fi
done

linux_user_path="/home/"'al'
mac_user_path="/Users/"'al'
win_user_path='C:\\Users\\'"al"

if rg -n --hidden --glob '!.git/**' --glob '!README.md' \
  -e "$linux_user_path" -e "$mac_user_path" -e "$win_user_path" .; then
  status=1
fi

if [[ $status -eq 0 ]]; then
  echo "Secret scan passed."
else
  echo "Secret scan found risky content." >&2
fi

exit "$status"
