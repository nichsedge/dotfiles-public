# dotfiles-public

Public, secret-free bootstrap repository for my workstation and mobile defaults. The public repo serves as the foundational layer for any new device; private credentials, API tokens, and machine-specific workflow shortcuts are layered later from `~/Projects/dotfiles-private`.

---

## 💻 Supported Environments

1. **Fedora Linux (KDE Plasma 6 / Wayland)** — Primary interactive workstation
2. **macOS (Darwin)** — Corporate / Office work laptop (Zero-sudo & Homebrew / `~/.local/bin`)
3. **Mobile Termux (Android)** — 100% Native Termux standalone companion (`aarch64`, headless)

---

## 🚀 First Install

### 1. Workstation: Fedora KDE (Plasma 6)

```bash
mkdir -p ~/Projects
git clone https://github.com/nichsedge/dotfiles-public.git ~/Projects/dotfiles-public
cd ~/Projects/dotfiles-public
./bootstrap.sh --profile fedora-kde
```

### 2. Office Laptop: macOS (Zero-Sudo Corporate Mode)

Designed for managed corporate laptops without admin/root access:

```bash
mkdir -p ~/Projects
git clone https://github.com/nichsedge/dotfiles-public.git ~/Projects/dotfiles-public
cd ~/Projects/dotfiles-public
./bootstrap.sh --profile macos
```

Or install via Homebrew bundle directly:
```bash
brew bundle --file=home/darwin/Brewfile
./install.sh
```

### 3. Mobile: Native Termux (Android)

For devices running 100% Native Termux standalone (running native `zsh`, `starship`, `uv`, `bun`, `go`, and `agy` CLI):

```bash
pkg update && pkg install -y git curl zsh
mkdir -p ~/Projects
git clone https://github.com/nichsedge/dotfiles-public.git ~/Projects/dotfiles-public
cd ~/Projects/dotfiles-public
./bootstrap.sh --profile mobile
```

> **Note**: Termux runs natively with Android bionic libc and `$PREFIX/bin` (PRoot has been pruned). The `mobile` profile runs headless without GUI configs and sets up lean shell defaults.

### Dry-Run & Skip Options

Preview changes safely without modifying the filesystem:

```bash
./bootstrap.sh --profile fedora-kde --dry-run
./install.sh --dry-run
# Or on mobile / headless:
./bootstrap.sh --profile mobile --dry-run
./install.sh --dry-run --headless
```

Skip package installations when the system is already configured:

```bash
./bootstrap.sh --profile fedora-kde --no-packages
```

---

## 📁 Managed Files

`install.sh` symlinks files from `home/common/` plus the platform directory (`home/linux/` or `home/darwin/`, detected via `uname -s`) into `$HOME`, backing up existing files first:

### Shared Core (`home/common/`)
- `.zshrc` (Modern interactive shell, plugins, unified ecosystem aliases)
- `.zshenv` (Path and runtime environment variables)
- `.gitconfig` (Global git config with delta pager and security hooks)
- `.profile`
- `.config/starship.toml` (Fast, cross-platform prompt)
- `.config/zellij/config.kdl` (Multiplexer config)
- `.config/ghostty/config` & `.config/ghostty/themes/dankcolors` (Ghostty terminal)

### Fedora KDE Plasma 6 (`home/linux/`)
- **KDE Plasma 6 (Wayland)**: `.config/kwinrc`, `.config/kcminputrc`, `.config/kglobalshortcutsrc`, `.config/kdeglobals`, `.config/krunnerrc`, `.config/plasmashellrc`.
- **System & Automation**: `.config/systemd/user/cliphist.service`, `.config/environment.d/cursor.conf`.
- **Desktop Helpers**: `.config/scripts/tailscale-menu.sh`, `tailscale-toggle.sh`, `.config/scripts/hotkey-cheatsheet.py`, `.local/bin/ghostty-tab`.
- **Launchers & Binaries**: `.local/share/applications/*.desktop`, `Projects/sync_git_repos.sh`, `.local/bin/update-antigravity`, `.local/bin/update-android-apps`, `.local/bin/google-chrome-stable`.

### macOS Workstation (`home/darwin/`)
- `home/darwin/Brewfile` (Homebrew CLI bundle + Ghostty cask)
- `scripts/first-install/macos.sh` (Zero-sudo bootstrap fallback to `~/.local/bin`)

### Untracked Private Overlay (Created Automatically)
- `~/.secrets`
- `~/.zshrc.local`
- `~/.profile.local`

---

## ⚡ Standardized Workstation Keybindings: Fedora KDE vs. macOS

To maintain muscle memory parity between Fedora KDE workstation and macOS office laptop:

| Action | Linux: Fedora KDE Plasma 6 (Workstation) | macOS: Raycast + AltTab (Office / Work) |
|:---|:---|:---|
| **Modifier Standard** | `Super` (Meta) = OS / Window management | `Cmd` (⌘) = OS / App management |
| **App Launcher** | `Super + Space` (KRunner) | `Cmd + Space` (Raycast) |
| **Terminal** | `Super + Return` (Ghostty) | `Cmd + Return` / `Cmd + T` |
| **Close Window** | `Super + Q` / `Alt + F4` | `Cmd + Q` (Quit) / `Cmd + W` (Close) |
| **Switch Windows** | `Alt + Tab` (Thumbnail Grid) | `Option + Tab` (AltTab app) |
| **Switch Same App** | `Alt + \`` | `Cmd + \`` |
| **Tile Left (Half)** | `Super + Left` | `Cmd + Option + Left` (Raycast Window Management) |
| **Tile Right (Half)** | `Super + Right` | `Cmd + Option + Right` (Raycast Window Management) |
| **Maximize Window** | `Super + Up` / `Super + F` | `Cmd + Option + Up` / `Ctrl + Cmd + F` |
| **Minimize / Unmaximize** | `Super + Down` | `Cmd + Option + Down` / `Cmd + M` |
| **Virtual Desktops** | `Super + 1..4` / `Ctrl + F1..F4` | `Ctrl + 1..4` (Mission Control) |
| **Browser** | `Super + B` | `Cmd + B` / Raycast hotkey |
| **File Manager** | `Super + E` (Dolphin) | `Cmd + E` (Finder) |
| **Overview / Grid** | `Super + W` / `Super + Tab` (Overview) | Mission Control (`Ctrl + Up` or Trackpad swipe) |
| **Clipboard History** | `Super + V` (Klipper / cliphist) | `Cmd + Shift + V` (Raycast Clipboard) |
| **Screenshot (Area)** | `Super + Shift + 4` / `Print` (Spectacle) | `Cmd + Shift + 4` |
| **Screenshot (Window)** | `Super + Shift + 5` (Spectacle Active) | `Cmd + Shift + 5` |
| **Tailscale / VPN** | `Super + Shift + T` | Menu bar item |
| **Lock Screen** | `Super + L` / `Super + Shift + Q` | `Cmd + Ctrl + Q` |

---

## 🔒 Private Overlay

After SSH and GitHub authentication are configured:

```bash
git clone git@github.com:nichsedge/dotfiles-private.git ~/Projects/dotfiles-private
```

The private repository manages production credentials, GCP keys, private agent skills, personal CV/notes, and machine-specific secrets. See `private.example/` for template structure.

---

## 🏛️ Repository Layout

- `home/common/`: Portable dotfiles shared across Fedora, macOS, and Termux.
- `home/linux/`: Linux desktop dotfiles (KDE Plasma 6, Wayland services, desktop launchers).
- `home/darwin/`: macOS-specific manifests (`Brewfile`).
- `scripts/first-install/`: Clean bootstrap scripts (`macos.sh`).
- `scripts/desktop/`: Desktop launchers (`antigravity-post-install.sh`).
- `scripts/tools/`: Utilities and repo security audits (`secret-scan.sh`, `install-dev-tools.sh`).
- `scripts/migration/`: Workstation migration and automated snapshot tools (`snapshot.sh`, `backup.sh`, `restore.sh`).
- `packages/`: Package manifests auto-synced by scheduled snapshot crons (`fedora-kde.txt`, `termux.txt`, `flatpaks.txt`, `uv-tools.txt`, etc.).
- `archive/`: Preserved historical configurations for **COSMIC**, **GNOME**, **Niri**, and **Hyprland/Waybar**.

---

## 🛡️ Public Safety & Secret Scans

Run before committing:

```bash
./scripts/tools/secret-scan.sh
git diff --check
```

The scan blocks private keys, API tokens, cloud credentials, and hardcoded home-path leaks.

---

## 🔄 Sync From Current Machine

```bash
./sync-from-home.sh
./scripts/tools/secret-scan.sh
```
