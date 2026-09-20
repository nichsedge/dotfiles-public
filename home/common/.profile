[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Source ~/.bashrc for bash login shells if it exists
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# Added by Toolbox App
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"



# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"
