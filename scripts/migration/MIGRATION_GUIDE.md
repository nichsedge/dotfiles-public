# Linux Migration Backup & Restore Guide

Use these scripts when reinstalling a workstation or moving from Ubuntu to Fedora.

## Backup

```bash
cd ~/Projects/dotfiles-public
./scripts/migration/backup.sh --dest /path/to/external-drive/migration-backup --mode dev --artifacts both --yes
```

Useful modes:

- `quick`: media and common user folders only.
- `dev`: common user folders plus `Projects` and public shell dotfiles.
- `full`: dev plus `.config`, `.local`, and `.var`.

Private files are excluded by default. To include `.ssh`, `.gnupg`, and `.secrets`, opt in explicitly:

```bash
./scripts/migration/backup.sh --dest /path/to/external-drive/migration-backup --mode full --include-private --yes
```

If you include private files, keep the backup encrypted or physically secured.

## Verify

```bash
cd /path/to/external-drive/migration-backup
sha256sum -c SHA256SUMS
```

## Restore

Copy or clone this public repo on the new machine, then run:

```bash
cd ~/Projects/dotfiles-public
./scripts/migration/restore.sh --src /path/to/external-drive/migration-backup --home "$HOME" --mode safe --yes
```

Run verification only:

```bash
./scripts/migration/restore.sh --src /path/to/external-drive/migration-backup --verify-only --yes
```

Restore modes:

- `safe`: keep existing files where possible.
- `overwrite`: overwrite files from the backup.
- `clean`: remove selected existing directories before restore.

## Fedora Package Restore

Create a Fedora package list in the backup folder:

```bash
cp packages/fedora-migration-example.txt /path/to/external-drive/migration-backup/packages-fedora.txt
```

Edit `packages-fedora.txt`, then restore. The restore script installs from this Fedora-specific list when `dnf` is available.
