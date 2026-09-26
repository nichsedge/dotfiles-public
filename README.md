# dotfiles-public

Public, secret-free bootstrap repo for my workstation defaults. The public repo is the first layer for a new device; private credentials and machine-specific workflow shortcuts are layered later from `~/Projects/dotfiles-private`.

## First Install: Fedora GNOME

```bash
mkdir -p ~/Projects
git clone https://github.com/nichsedge/dotfiles-public.git ~/Projects/dotfiles-public
cd ~/Projects/dotfiles-public
./bootstrap.sh --profile fedora-gnome
```

## First Install: Mobile / Headless (Termux PRoot Debian)

For Android devices (e.g. Xiaomi 14T Pro) running Termux + PRoot Debian to support full glibc runtimes (`uv`, `bun`, `agy` CLI):

```bash
# 1. In native Termux: install PRoot Debian
pkg update && pkg install proot-distro
proot-distro install debian
proot-distro login debian --shared-tmp -- /bin/zsh

# 2. In PRoot Debian: bootstrap dotfiles
apt-get update && apt-get install -y git curl sudo
mkdir -p ~/Projects
git clone https://github.com/nichsedge/dotfiles-public.git ~/Projects/dotfiles-public
cd ~/Projects/dotfiles-public
./bootstrap.sh --profile mobile
```

> **Note**: PRoot hardcodes `/bin/bash -l` by default on login. `bootstrap.sh --profile mobile` automatically appends an auto-switch to `~/.bashrc`, or you can launch directly with `proot-distro login debian --shared-tmp -- /bin/zsh`.

Preview without changing the machine:

```bash
./bootstrap.sh --profile fedora-gnome --dry-run
./install.sh --dry-run
# Or on mobile:
./bootstrap.sh --profile mobile --dry-run
./install.sh --dry-run --headless
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
- `.config/starship.toml`
- `.config/zellij/config.kdl`
- `.config/ghostty/config`
- `.config/ghostty/themes/dankcolors`

Platform-specific extras (Linux desktop):
- **Niri Compositor & DMS**: `.config/niri/config.kdl`, `hypridle.conf`, and modular `dms/*.kdl`.
- **Desktop Helpers**: `.config/scripts/tailscale-menu.sh`, `tailscale-toggle.sh`, `.local/bin/toggle-gnome-overview`.
- **GNOME Synchronization**: `scripts/desktop/gnome/set-config.sh` (standardizes GNOME 1:1 with Niri/Mac).
- **Launchers & Automation**: `.local/share/applications/*.desktop`, `Projects/sync_git_repos.sh`, `Projects/misc/update_antigravity.sh`.

Private files are created if missing and are never committed:

- `~/.secrets`
- `~/.zshrc.local`
- `~/.profile.local`

## ⚡ Standardized Cross-Platform Keybinding & Multitasking Standard

To eliminate muscle memory friction across Linux (Niri + GNOME), macOS, and Windows:

| Action | Linux: Niri (Primary) | Linux: GNOME (Fallback) | macOS (Raycast + AltTab) | Windows (PowerToys) |
|---|---|---|---|---|
| **Modifier Rule** | `Super` = OS / Window | `Super` = OS / Window | `Cmd` = OS / Window | `Win` = OS / Window |
| **App Launcher** | `Super + Space` / `Super + D` | `Super + Space` / `Super` | `Cmd + Space` (Raycast) | `Win + Space` (PowerToys Run) |
| **Terminal** | `Super + Return` / `Super + T` | `Super + Return` / `Super + T` | `Cmd + Return` / `Cmd + T` | `Win + Return` (Terminal) |
| **Close Window** | `Super + Q` / `Alt + F4` | `Super + Q` / `Alt + F4` | `Cmd + Q` / `Cmd + W` | `Win + Q` / `Alt + F4` |
| **Switch Windows** | `Alt + Tab` / `Super + Tab` | `Alt + Tab` / `Super + Tab` | `Option + Tab` (AltTab app) | `Alt + Tab` |
| **Switch Same App** | `Alt + \`` / `Super + \`` | `Alt + \`` / `Super + \`` | `Cmd + \`` | `Ctrl + Win + Tab` / custom |
| **Tile Left (Half)** | `Super + Left` / `Super + H` | `Super + Left` | `Cmd + Alt + Left` | `Win + Left` |
| **Tile Right (Half)**| `Super + Right` / `Super + L`| `Super + Right` | `Cmd + Alt + Right` | `Win + Right` |
| **Maximize / Edges** | `Super + F` / `Super + M` | `Super + Up` / `Super + F` | `Cmd + Alt + Up` / `Cmd + Ctrl + F` | `Win + Up` |
| **Unmaximize** | `Super + Alt + Down` | `Super + Down` | `Cmd + Alt + Down` | `Win + Down` |
| **Direct Workspace**| `Super + 1..9` | `Super + 1..9` | `Ctrl + 1..9` | `Win + Ctrl + 1..9` |
| **Browser** | `Super + B` | `Super + B` | `Cmd + B` / Raycast hotkey | `Win + B` / custom |
| **File Manager** | `Super + E` | `Super + E` | `Cmd + E` (Finder) | `Win + E` |
| **Overview** | `Super + O` | `Super + O` | Mission Control / Swipe | `Win + Tab` |
| **Clipboard History**| `Super + V` | `Super + V` | `Cmd + Shift + V` / Raycast | `Win + V` |
| **Screenshot (Screen)**| `Print` / `Super + Shift + 3` | `Print` / `Super + Shift + 3` | `Cmd + Shift + 3` | `Win + PrtScn` |
| **Screenshot (Area)** | `Super + Shift + 4` | `Super + Shift + 4` | `Cmd + Shift + 4` | `Win + Shift + S` |
| **Screenshot (Window)**| `Super + Shift + 5` | `Super + Shift + 5` | `Cmd + Shift + 5` | `Alt + PrtScn` |
| **VPN / Tailscale** | `Super + Shift + T` | `Super + Shift + T` | Menu bar | Tray icon |
| **Power / Lock** | `Super + Shift + Q` / `Super + Alt + L` | `Super + Shift + Q` | `Cmd + Ctrl + Q` | `Win + L` |

## Private Overlay

After SSH/GitHub auth is ready:

```bash
git clone git@github.com:nichsedge/dotfiles-private.git ~/Projects/dotfiles-private
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
