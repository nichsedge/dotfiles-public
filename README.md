# dotfiles-public

Public dotfiles repo with no secrets.

## Managed files
- `.zshrc`
- `.zshenv`
- `.gitconfig`
- `.profile`

## Install
```bash
./install.sh
```

## First-time setup on a new laptop
```bash
git clone git@github.com:nichsedge/dotfiles-public.git ~/dotfiles-public
cd ~/dotfiles-public
./bootstrap.sh
```

If you want to skip package installation:
```bash
./bootstrap.sh --no-packages
```

## Sync from current machine
```bash
./sync-from-home.sh
```

## Private local settings (not committed)
- `~/.zshrc.local`
- `~/.secrets`

`.zshrc` loads those files only if they exist.
