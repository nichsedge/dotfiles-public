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

## Sync from current machine
```bash
./sync-from-home.sh
```

## Private local settings (not committed)
- `~/.zshrc.local`
- `~/.secrets`

`.zshrc` loads those files only if they exist.
