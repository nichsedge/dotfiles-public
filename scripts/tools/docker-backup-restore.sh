#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  docker-backup-restore.sh backup DIR [IMAGE ...]
  docker-backup-restore.sh restore DIR

Back up Docker images to tar.gz files or restore all tar/tar.gz images from a directory.
If no IMAGE values are provided during backup, all local images with tags are saved.
USAGE
}

cmd="${1:-}"
dir="${2:-}"
shift 2 2>/dev/null || true

[[ -n "$cmd" && -n "$dir" ]] || { usage; exit 1; }

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found" >&2
  exit 1
fi

safe_name() {
  printf '%s' "$1" | sed -E 's#[/:@]+#_#g; s#[^A-Za-z0-9_.-]#_#g'
}

case "$cmd" in
  backup)
    mkdir -p "$dir"
    if [[ $# -eq 0 ]]; then
      mapfile -t images < <(docker images --format '{{.Repository}}:{{.Tag}}' | grep -v '<none>')
    else
      images=("$@")
    fi
    for image in "${images[@]}"; do
      out="${dir}/$(safe_name "$image").tar.gz"
      echo "Saving ${image} -> ${out}"
      docker save "$image" | gzip > "$out"
    done
    ;;
  restore)
    shopt -s nullglob
    files=("$dir"/*.tar "$dir"/*.tar.gz "$dir"/*.tgz)
    [[ ${#files[@]} -gt 0 ]] || { echo "No image archives found in ${dir}"; exit 1; }
    for file in "${files[@]}"; do
      echo "Loading ${file}"
      case "$file" in
        *.tar) docker load -i "$file" ;;
        *.tar.gz|*.tgz) gzip -dc "$file" | docker load ;;
      esac
    done
    ;;
  -h|--help) usage ;;
  *) echo "Unknown command: $cmd" >&2; usage; exit 1 ;;
esac
