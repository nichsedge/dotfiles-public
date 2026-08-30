#!/usr/bin/env bash
set -euo pipefail
# snapshot.sh — dump current machine state into packages/* manifests
# Usage: ./scripts/migration/snapshot.sh [--commit]
# Lean: only captures top-level user tools, not base OS deps
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACKAGES_DIR="$REPO_ROOT/packages"
mkdir -p "$PACKAGES_DIR"

log(){ printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

COMMIT=false
[[ "${1:-}" == "--commit" ]] && COMMIT=true

# 1. flatpak apps (decluttered, sorted)
log "flatpak apps -> packages/flatpaks.txt"
flatpak list --app --columns=application 2>/dev/null | sort -u > "$PACKAGES_DIR/flatpaks.txt" || echo "# no flatpak" > "$PACKAGES_DIR/flatpaks.txt"

# 2. uv tools
log "uv tools -> packages/uv-tools.txt"
if command -v uv >/dev/null 2>&1; then
  uv tool list 2>/dev/null | awk '/^[^ ]+ v/ {print $1}' | sort -u > "$PACKAGES_DIR/uv-tools.txt" || true
  # also capture full list for reference
  uv tool list 2>/dev/null > "$PACKAGES_DIR/uv-tools-full.txt" || true
else
  echo "# uv not installed" > "$PACKAGES_DIR/uv-tools.txt"
fi
# remove empty
[[ -s "$PACKAGES_DIR/uv-tools.txt" ]] || rm -f "$PACKAGES_DIR/uv-tools.txt" "$PACKAGES_DIR/uv-tools-full.txt"

# 3. bun global
log "bun global -> packages/bun-global.json"
if [[ -f "$HOME/.bun/install/global/package.json" ]]; then
  cp "$HOME/.bun/install/global/package.json" "$PACKAGES_DIR/bun-global.json"
else
  rm -f "$PACKAGES_DIR/bun-global.json"
fi

# 4. npm global (parseable list, just names)
log "npm global -> packages/npm-global.txt"
if command -v npm >/dev/null 2>&1; then
  npm list -g --depth=0 --json 2>/dev/null | python3 -c "import json,sys; j=json.load(sys.stdin); print(chr(10).join(sorted(j.get('dependencies',{}).keys())))" > "$PACKAGES_DIR/npm-global.txt" || true
  [[ -s "$PACKAGES_DIR/npm-global.txt" ]] || echo "@anthropic-ai/claude-code" > "$PACKAGES_DIR/npm-global.txt"
else
  rm -f "$PACKAGES_DIR/npm-global.txt"
fi

# 5. cargo
log "cargo -> packages/cargo-tools.txt"
if command -v cargo >/dev/null 2>&1; then
  cargo install --list 2>/dev/null | awk '/^[^ ]+ v/ {print $1}' | sort -u > "$PACKAGES_DIR/cargo-tools.txt" || true
  [[ -s "$PACKAGES_DIR/cargo-tools.txt" ]] || rm -f "$PACKAGES_DIR/cargo-tools.txt"
fi

# 6. dnf: fedora-gnome.txt is curated lean list — no auto-dump. Edit it manually if you add system packages.

log "snapshot done. Files:"
ls -l "$PACKAGES_DIR"/*.txt "$PACKAGES_DIR"/*.json 2>/dev/null || true

if [[ "$COMMIT" == true ]]; then
  log "committing snapshot"
  git -C "$REPO_ROOT" add packages/flatpaks.txt packages/uv-tools.txt packages/uv-tools-full.txt packages/bun-global.json packages/npm-global.txt packages/cargo-tools.txt packages/dnf-history-snapshot.txt 2>/dev/null || true
  git -C "$REPO_ROOT" diff --cached --stat || true
fi
