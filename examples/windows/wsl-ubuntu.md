# WSL Ubuntu Reference

Basic WSL shell setup:

```bash
sudo apt install -y zsh
chsh -s "$(command -v zsh)"
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Optional Windows projects link, using placeholders:

```bash
ln -s /mnt/c/Users/<windows-user>/Projects "$HOME/Projects"
```
