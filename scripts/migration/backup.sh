#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: backup.sh [--dest PATH] [--mode quick|dev|full] [--artifacts mirror|archive|both] [--home PATH] [--yes] [--dry-run] [--include-private] [--skip-docker] [--no-android] [--no-projects] [--no-bin]

Creates a migration backup for reinstalling or moving Linux workstations.
Private files such as .ssh, .gnupg, and .secrets are excluded unless --include-private is set.
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

DEST="$HOME/migration-backup"
SOURCE_HOME="$HOME"
MODE=""
ARTIFACTS=""
ASSUME_YES=false
DRY_RUN=false
INCLUDE_PRIVATE=false
SKIP_DOCKER=false
BACKUP_ANDROID=true
BACKUP_PROJECTS=true
BACKUP_BIN=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dest) DEST="${2:-}"; shift 2 ;;
    --home) SOURCE_HOME="${2:-}"; shift 2 ;;
    --mode) MODE="${2:-}"; shift 2 ;;
    --artifacts) ARTIFACTS="${2:-}"; shift 2 ;;
    --yes) ASSUME_YES=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --include-private) INCLUDE_PRIVATE=true; shift ;;
    --skip-docker) SKIP_DOCKER=true; shift ;;
    --no-android) BACKUP_ANDROID=false; shift ;;
    --no-projects) BACKUP_PROJECTS=false; shift ;;
    --no-bin) BACKUP_BIN=false; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ "$ASSUME_YES" != true ]]; then
  DEST="$(ask 'Backup destination folder' "$DEST")"
  SOURCE_HOME="$(ask 'Source home folder' "$SOURCE_HOME")"
  MODE="$(ask 'Mode (quick/dev/full)' "dev")"
  ARTIFACTS="$(ask 'Artifacts (mirror/archive/both)' "both")"
  local_docker="$(ask 'Export docker images? (yes/no)' "no")"
  [[ "$local_docker" =~ ^[Yy] ]] || SKIP_DOCKER=true
else
  MODE="${MODE:-dev}"
  ARTIFACTS="${ARTIFACTS:-both}"
fi

case "$MODE" in quick|dev|full) ;; *) echo "Invalid --mode: $MODE" >&2; exit 1 ;; esac
case "$ARTIFACTS" in mirror|archive|both) ;; *) echo "Invalid --artifacts: $ARTIFACTS" >&2; exit 1 ;; esac

if [[ ! -d "$SOURCE_HOME" ]]; then
  echo "Source home does not exist: $SOURCE_HOME" >&2
  exit 1
fi

if [[ "$INCLUDE_PRIVATE" == true ]]; then
  warn "Including private files such as .ssh, .gnupg, and .secrets. Protect the backup destination."
fi

if [[ "$DRY_RUN" != true ]]; then
  mkdir -p "$DEST"
  [[ -w "$DEST" ]] || { echo "Destination not writable: $DEST" >&2; exit 1; }
else
  run mkdir -p "$DEST"
fi

LOG_FILE="$DEST/backup.log"
if [[ "$DRY_RUN" != true ]]; then
  exec > >(tee -a "$LOG_FILE") 2>&1
fi

log "Starting backup"
log "Destination: $DEST"
log "Source home: $SOURCE_HOME"
log "Mode: $MODE"
log "Artifacts: $ARTIFACTS"
log "Include private: $INCLUDE_PRIVATE"

MIRROR_ROOT="$DEST/mirror"
run mkdir -p "$MIRROR_ROOT"

EXCLUDE_FILE="$(mktemp)"
trap 'rm -f "$EXCLUDE_FILE"' EXIT
cat > "$EXCLUDE_FILE" <<'EXCLUDE'
.cache/
.local/share/Trash/
**/node_modules/
**/build/
**/dist/
.gradle/caches/
.npm/_cacache/
.cargo/registry/
*.tmp
*.temp
EXCLUDE

mirror_paths=(Documents Downloads Desktop Music Pictures Videos AppImages)
if [[ "$MODE" != "quick" ]]; then
  mirror_paths+=(.zshrc .bashrc .profile .gitconfig)
fi
if [[ "$MODE" == "dev" || "$MODE" == "full" ]]; then
  mirror_paths+=(Projects)
fi
if [[ "$MODE" == "full" ]]; then
  mirror_paths+=(.config .local .var)
fi
if [[ "$INCLUDE_PRIVATE" == true ]]; then
  mirror_paths+=(.ssh .gnupg .secrets)
fi

if [[ "$ARTIFACTS" == "mirror" || "$ARTIFACTS" == "both" ]]; then
  log "Running mirror backup with rsync"
  for p in "${mirror_paths[@]}"; do
    if [[ -e "$SOURCE_HOME/$p" ]]; then
      log "Mirroring $p"
      run rsync -aHAX --delete-delay --info=progress2 --exclude-from="$EXCLUDE_FILE" "$SOURCE_HOME/$p" "$MIRROR_ROOT/"
    fi
  done
fi

archive_paths=(.zshrc .bashrc .profile .gitconfig)
if [[ "$MODE" == "dev" || "$MODE" == "full" ]]; then
  archive_paths+=(.codex .claude)
fi
if [[ "$MODE" == "full" ]]; then
  archive_paths+=(.config .local .var)
fi
if [[ "$INCLUDE_PRIVATE" == true ]]; then
  archive_paths+=(.ssh .gnupg .secrets)
fi

if [[ "$ARTIFACTS" == "archive" || "$ARTIFACTS" == "both" ]]; then
  if [[ "$BACKUP_ANDROID" == true && -d "$SOURCE_HOME/Android" ]]; then
    log "Creating Android.zip"
    run sh -c "cd '$SOURCE_HOME' && zip -rq '$DEST/Android.zip' Android"
  fi
  if [[ "$BACKUP_PROJECTS" == true && -d "$SOURCE_HOME/Projects" ]]; then
    log "Creating Projects.zip"
    run sh -c "cd '$SOURCE_HOME' && zip -rq '$DEST/Projects.zip' Projects"
  fi
  if [[ "$BACKUP_BIN" == true && -d "$SOURCE_HOME/bin" ]]; then
    log "Creating bin.zip"
    run sh -c "cd '$SOURCE_HOME' && zip -rq '$DEST/bin.zip' bin"
  fi

  DOT_ARCHIVE="$DEST/dotfiles.tar.gz"
  log "Creating dotfiles.tar.gz"
  if [[ "$DRY_RUN" == true ]]; then
    printf 'DRY-RUN tar from %q to %q with paths:' "$SOURCE_HOME" "$DOT_ARCHIVE"
    printf ' %q' "${archive_paths[@]}"
    printf '\n'
  elif have pigz; then
    tar -C "$SOURCE_HOME" --exclude-from="$EXCLUDE_FILE" -cf - "${archive_paths[@]}" 2>/dev/null | pigz -1 > "$DOT_ARCHIVE"
  else
    tar -C "$SOURCE_HOME" --exclude-from="$EXCLUDE_FILE" -czf "$DOT_ARCHIVE" "${archive_paths[@]}" 2>/dev/null || true
  fi
fi

log "Exporting package manifests"
have apt-mark && run sh -c "apt-mark showmanual > '$DEST/ubuntu_manual_packages.txt'"
have flatpak && run sh -c "flatpak list --app --columns=application > '$DEST/ubuntu_flatpaks.txt'"
have snap && run sh -c "snap list > '$DEST/ubuntu_snaps.txt'"

if [[ "$SKIP_DOCKER" != true && -x "$(command -v docker || true)" ]]; then
  log "Exporting docker images"
  if [[ "$DRY_RUN" == true ]]; then
    echo "DRY-RUN docker image save ... > $DEST/docker-images.tar.gz"
  else
    mapfile -t images < <(docker image ls --format '{{.Repository}}:{{.Tag}}' | grep -v '^<none>:' || true)
    if [[ ${#images[@]} -gt 0 ]]; then
      docker image save "${images[@]}" | gzip -1 > "$DEST/docker-images.tar.gz"
      printf '%s\n' "${images[@]}" > "$DEST/docker-images-list.txt"
    fi
  fi
fi

log "Writing manifest"
if [[ "$DRY_RUN" == true ]]; then
  echo "DRY-RUN write $DEST/manifest.txt"
else
  {
    echo "backup_created_at=$(date -Is)"
    echo "host=$(hostname)"
    echo "user=$(id -un)"
    echo "home=$SOURCE_HOME"
    echo "mode=$MODE"
    echo "artifacts=$ARTIFACTS"
    echo "include_private=$INCLUDE_PRIVATE"
  } > "$DEST/manifest.txt"
fi

log "Generating SHA256SUMS"
if [[ "$DRY_RUN" == true ]]; then
  echo "DRY-RUN generate $DEST/SHA256SUMS"
else
  (cd "$DEST" && find . -maxdepth 1 -type f ! -name 'SHA256SUMS' -printf '%P\n' | sort | xargs -r sha256sum > SHA256SUMS)
fi

log "Backup complete"
