# Public, portable zsh configuration. Private values belong in ~/.secrets or ~/.zshrc.local.

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME="${ZSH_THEME:-robbyrussell}"

plugins=(git)
[[ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions" ]] && plugins+=(zsh-autosuggestions)
[[ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Private env vars and identities. This file must stay untracked and mode 0600.
[[ -r "$HOME/.secrets" ]] && source "$HOME/.secrets"

path_prepend() {
  [[ -d "$1" ]] && case ":$PATH:" in *":$1:"*) ;; *) PATH="$1:$PATH" ;; esac
}

path_append() {
  [[ -d "$1" ]] && case ":$PATH:" in *":$1:"*) ;; *) PATH="$PATH:$1" ;; esac
}

path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.bun/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.opencode/bin"

export PROJECT_DIR="${PROJECT_DIR:-$HOME/Projects}"
export AIRFLOW_HOME="${AIRFLOW_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/airflow}"
export TMPDIR="${TMPDIR:-${XDG_RUNTIME_DIR:-$HOME/tmp}}"
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"

alias c='clear'
alias l='ls -lh --color=auto'
alias la='ls -A'
alias ll='ls -alF'
alias l.='ls -d .* --color=auto'
alias lt='ls -lhS --group-directories-first'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias now='date +%T'
alias ports='ss -tulpn'
alias count='find . -type f | wc -l'
alias reload='source ~/.zshrc && echo ".zshrc reloaded"'

if command -v apt-get >/dev/null 2>&1; then
  alias up='sudo apt update && sudo apt upgrade -y'
  alias clean='sudo apt autoremove -y && sudo apt clean'
elif command -v dnf >/dev/null 2>&1; then
  alias up='sudo dnf upgrade -y'
  alias clean='sudo dnf autoremove -y && sudo dnf clean all'
elif command -v pacman >/dev/null 2>&1; then
  alias up='sudo pacman -Syu'
  alias clean='sudo pacman -Sc'
fi

# Git identity helpers read values from ~/.secrets when present.
gci() {
  git config user.email "${GIT_EMAIL_PERSONAL:-personal@example.com}"
  git config user.name "${GIT_NAME_PERSONAL:-Personal Name}"
}

gcw() {
  git config user.email "${GIT_EMAIL_WORK:-work@example.com}"
  git config user.name "${GIT_NAME_WORK:-Work Name}"
}

if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi

if command -v uvx >/dev/null 2>&1; then
  eval "$(uvx --generate-shell-completion zsh)"
fi

[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Machine-specific aliases, paths, project shortcuts, and cloud env vars.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
export PATH
