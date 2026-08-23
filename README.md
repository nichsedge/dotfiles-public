# dotfiles-public

Public, secret-free bootstrap repo for my workstation defaults. The public repo is the first layer for a new device; private credentials and machine-specific workflow shortcuts are layered later from `~/Projects/creds`.

## First Install: Fedora GNOME

```bash
mkdir -p ~/Projects
git clone https://github.com/nichsedge/dotfiles-public.git ~/Projects/dotfiles-public
cd ~/Projects/dotfiles-public
./bootstrap.sh --profile fedora-gnome
```

Preview without changing the machine:

```bash
./bootstrap.sh --profile fedora-gnome --dry-run
./install.sh --dry-run
```

Skip package installs when the OS is already prepared:

```bash
./bootstrap.sh --profile fedora-gnome --no-packages
```

## Managed Files

`install.sh` symlinks files from `home/common/` plus the platform directory (`home/linux/` or `home/darwin/`, detected via `uname -s`) into `$HOME`, backing up existing files first:

- `.zshrc`
- `.zshenv`
- `.gitconfig`
- `.profile`
- `.config/kitty/kitty.conf`

Platform-specific extras (Linux only): `Projects/sync_git_repos.sh`, `Projects/misc/update_antigravity.sh`, and `.local/share/applications/*.desktop`.

Private files are created if missing and are never committed:

- `~/.secrets`
- `~/.zshrc.local`
- `~/.profile.local`

## Private Overlay

After SSH/GitHub auth is ready:

```bash
git clone git@github.com:nichsedge/creds.git ~/Projects/creds
```

Use the private repo for real credentials, GCP JSON files, SSH notes, CV/personal docs, project aliases, and machine-specific environment variables. See `private.example/` for the expected local-file shape.

## Layout

- `home/common/`: portable dotfiles shared across Linux and macOS.
- `home/linux/`: Linux-only dotfiles (desktop launchers, misc scripts).
- `home/darwin/`: macOS-only dotfiles, including a Homebrew `Brewfile` (`brew bundle --file=home/darwin/Brewfile`).
- `scripts/first-install/`: Fedora-first bootstrap plus Ubuntu/Arch secondary scripts.
- `scripts/desktop/gnome/`: GNOME and Nautilus helpers.
- `scripts/desktop/gnome/apply-dash-to-dock-grid-icon.sh`: reapplies the MacTahoe app-grid icon after Dash to Dock updates.
- `scripts/desktop/antigravity-post-install.sh`: optional Antigravity desktop launcher setup.
- `scripts/tools/`: reusable utilities and repo checks.
- `scripts/migration/`: backup/restore tooling for workstation migrations.
- `packages/`: curated package references.
- `examples/`: sanitized templates for Git, GCP, Terraform, and personal config.
- `private.example/`: examples for private overlay files.

## Public Safety Checks

Run before committing or pushing:

```bash
./scripts/tools/secret-scan.sh
git diff --check
```

The scan blocks common private-key, token, cloud credential, and hardcoded user-path leaks outside approved examples.

## Sync From Current Machine

```bash
./sync-from-home.sh
./scripts/tools/secret-scan.sh
```

Review the diff carefully. Syncing from `$HOME` can reintroduce private paths or machine-specific values.
