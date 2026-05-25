#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: restore.sh [--src BACKUP_DIR] [--home TARGET_HOME] [--mode safe|overwrite|clean] [--verify-only] [--dry-run] [--skip-packages] [--skip-flatpaks] [--skip-docker] [--yes]

Restores a migration backup. Safe mode keeps existing files when possible.
USAGE
}

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

ask() {
  local prompt="$1" default="$2" answer
  read -r -p "$prompt [$default]: " answer
  printf '%s' "${answer:-$default}"
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

SRC="$HOME/migration-backup"
TARGET_HOME="$HOME"
MODE=""
VERIFY_ONLY=false
DRY_RUN=false
SKIP_PACKAGES=false
SKIP_FLATPAKS=false
SKIP_DOCKER=false
ASSUME_YES=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --src) SRC="${2:-}"; shift 2 ;;
    --home) TARGET_HOME="${2:-}"; shift 2 ;;
    --mode) MODE="${2:-}"; shift 2 ;;
    --verify-only) VERIFY_ONLY=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --skip-packages) SKIP_PACKAGES=true; shift ;;
    --skip-flatpaks) SKIP_FLATPAKS=true; shift ;;
    --skip-docker) SKIP_DOCKER=true; shift ;;
    --yes) ASSUME_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ "$ASSUME_YES" != true ]]; then
  SRC="$(ask 'Backup source folder' "$SRC")"
  TARGET_HOME="$(ask 'Target home folder' "$TARGET_HOME")"
  MODE="$(ask 'Restore mode (safe/overwrite/clean)' "safe")"
else
  MODE="${MODE:-safe}"
fi

case "$MODE" in safe|overwrite|clean) ;; *) echo "Invalid --mode: $MODE" >&2; exit 1 ;; esac

if [[ ! -d "$SRC" ]]; then
  if [[ "$DRY_RUN" == true || "$VERIFY_ONLY" == true ]]; then
    warn "Backup source not found: $SRC"
  else
    echo "Backup source not found: $SRC" >&2
    exit 1
  fi
fi
if [[ ! -d "$TARGET_HOME" ]]; then
  if [[ "$DRY_RUN" == true ]]; then
    run mkdir -p "$TARGET_HOME"
  else
    echo "Target home not found: $TARGET_HOME" >&2
    exit 1
  fi
fi

LOG_FILE="$SRC/restore.log"
CONFLICT_LOG="$SRC/restore-conflicts.log"
if [[ "$DRY_RUN" != true && -d "$SRC" ]]; then
  : > "$CONFLICT_LOG"
  exec > >(tee -a "$LOG_FILE") 2>&1
fi

log "Starting restore"
log "Source: $SRC"
log "Target: $TARGET_HOME"
log "Mode: $MODE"

if [[ -f "$SRC/SHA256SUMS" ]]; then
  log "Verifying SHA256SUMS"
  if [[ "$DRY_RUN" == true ]]; then
    echo "DRY-RUN sha256sum -c $SRC/SHA256SUMS"
  else
    (cd "$SRC" && sha256sum -c SHA256SUMS)
  fi
else
  warn "SHA256SUMS not found, skipping integrity check"
fi

if [[ "$VERIFY_ONLY" == true ]]; then
  log "Verify-only complete"
  exit 0
fi

restore_with_rsync() {
  local from="$1" to="$2"
  case "$MODE" in
    safe) run rsync -aHAX --ignore-existing --info=progress2 "$from" "$to" ;;
    overwrite) run rsync -aHAX --info=progress2 "$from" "$to" ;;
    clean)
      local base
      base="$(basename "${from%/}")"
      run rm -rf "$to/$base"
      run rsync -aHAX --info=progress2 "$from" "$to"
      ;;
  esac
}

if [[ -d "$SRC/mirror" ]]; then
  log "Restoring mirror content"
  while IFS= read -r -d '' dir; do
    rel="${dir#"$SRC/mirror/"}"
    if [[ "$MODE" == "safe" && -e "$TARGET_HOME/$rel" && "$DRY_RUN" != true ]]; then
      echo "$rel" >> "$CONFLICT_LOG"
    fi
    restore_with_rsync "$dir" "$TARGET_HOME/"
  done < <(find "$SRC/mirror" -mindepth 1 -maxdepth 1 -print0)
fi

restore_zip_dir() {
  local zip_name="$1"
  local zip_path="$SRC/$zip_name"
  [[ -f "$zip_path" ]] || return 0
  log "Restoring $zip_name"
  case "$MODE" in
    safe) run unzip -nq "$zip_path" -d "$TARGET_HOME" ;;
    overwrite) run unzip -oq "$zip_path" -d "$TARGET_HOME" ;;
    clean)
      local top
      top="$(zipinfo -1 "$zip_path" | head -n1 | cut -d/ -f1)"
      [[ -n "$top" ]] && run rm -rf "$TARGET_HOME/$top"
      run unzip -oq "$zip_path" -d "$TARGET_HOME"
      ;;
  esac
}

restore_zip_dir "Android.zip"
restore_zip_dir "Projects.zip"
restore_zip_dir "bin.zip"

if [[ -f "$SRC/dotfiles.tar.gz" ]]; then
  log "Restoring dotfiles.tar.gz"
  case "$MODE" in
    safe) run tar -xzf "$SRC/dotfiles.tar.gz" -C "$TARGET_HOME" --skip-old-files ;;
    overwrite) run tar -xzf "$SRC/dotfiles.tar.gz" -C "$TARGET_HOME" ;;
    clean)
      run rm -rf "$TARGET_HOME/.config" "$TARGET_HOME/.local" "$TARGET_HOME/.codex" "$TARGET_HOME/.claude"
      run tar -xzf "$SRC/dotfiles.tar.gz" -C "$TARGET_HOME"
      ;;
  esac
fi

if [[ -d "$TARGET_HOME/.ssh" ]]; then
  run chmod 700 "$TARGET_HOME/.ssh"
  if [[ "$DRY_RUN" == true ]]; then
    echo "DRY-RUN chmod 600 files under $TARGET_HOME/.ssh"
  else
    find "$TARGET_HOME/.ssh" -type f -exec chmod 600 {} + || true
  fi
fi
if [[ -d "$TARGET_HOME/.gnupg" ]]; then
  run chmod 700 "$TARGET_HOME/.gnupg"
fi

if [[ "$SKIP_PACKAGES" != true && -f "$SRC/packages-fedora.txt" && -x "$(command -v dnf || true)" ]]; then
  log "Installing Fedora packages from packages-fedora.txt"
  [[ "$DRY_RUN" != true ]] && : > "$SRC/failed-packages.log"
  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    if [[ "$DRY_RUN" == true ]]; then
      echo "DRY-RUN sudo dnf install -y $pkg"
    elif ! sudo dnf install -y "$pkg"; then
      echo "$pkg" >> "$SRC/failed-packages.log"
    fi
  done < "$SRC/packages-fedora.txt"
fi

if [[ "$SKIP_FLATPAKS" != true && -f "$SRC/ubuntu_flatpaks.txt" && -x "$(command -v flatpak || true)" ]]; then
  log "Installing flatpaks"
  run flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  while IFS= read -r appid; do
    [[ -z "$appid" ]] && continue
    run flatpak install -y flathub "$appid"
  done < "$SRC/ubuntu_flatpaks.txt"
fi

if [[ "$SKIP_DOCKER" != true && -f "$SRC/docker-images.tar.gz" && -x "$(command -v docker || true)" ]]; then
  log "Loading docker images"
  if [[ "$DRY_RUN" == true ]]; then
    echo "DRY-RUN gzip -dc $SRC/docker-images.tar.gz | docker image load"
  else
    gzip -dc "$SRC/docker-images.tar.gz" | docker image load
  fi
fi

if [[ "$DRY_RUN" != true && -s "${CONFLICT_LOG:-}" ]]; then
  warn "Some paths already existed in safe mode. See: $CONFLICT_LOG"
fi

log "Restore complete"
