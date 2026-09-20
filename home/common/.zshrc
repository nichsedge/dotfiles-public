# ==============================================================================
# Workstation Shell Configuration (Amal @ al@fedora)
# ==============================================================================

# Locale & Terminal Settings
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
if [ -z "$TERM" ] || [ "$TERM" = "dumb" ] || ! infocmp "$TERM" >/dev/null 2>&1; then
  export TERM=xterm-256color
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="" # Disabled — using Starship prompt instead
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source "$ZSH/oh-my-zsh.sh"

# ZSH Autosuggestions Tweaks (ergonomic for mobile virtual keyboard)
bindkey '^ ' autosuggest-accept 2>/dev/null || true
bindkey '^f' autosuggest-accept 2>/dev/null || true
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Secrets (API keys, tokens, environment secrets)
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"

# Shell Integrations
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# FZF Key-bindings & Search Configuration
if [[ -f /usr/share/fzf/shell/key-bindings.zsh ]]; then
  source /usr/share/fzf/shell/key-bindings.zsh
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
elif [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
fi
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--height 60% --border --info=inline"

# CLI Completions (uv, bun, direnv)
command -v uv >/dev/null 2>&1 && eval "$(uv generate-shell-completion zsh)"
command -v uvx >/dev/null 2>&1 && eval "$(uvx --generate-shell-completion zsh)"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Google Cloud SDK Integrations
[[ -f "$HOME/bin/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/bin/google-cloud-sdk/path.zsh.inc"
[[ -f "$HOME/bin/google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/bin/google-cloud-sdk/completion.zsh.inc"

# OCaml (opam) Environment
[[ -r "$HOME/.opam/opam-init/init.zsh" ]] && source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2>&1

# ==============================================================================
# Environment Variables & PATH
# ==============================================================================
export TERMINAL="ghostty"
export COLORTERM="truecolor"

# Runtime Homes
export JAVA_HOME="/usr/lib/jvm/java-openjdk"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
export GO_HOME="$HOME/bin/go"
export NPM_DIR="$HOME/bin/node"
export BUN_INSTALL="$HOME/.bun"

# Project & SSOT Locations
export PROJECT_DIR="$HOME/Projects"
export BLOG_PATH="$PROJECT_DIR/digital-graveyard/content"
export AIRFLOW_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/airflow"
export TMPDIR="${XDG_RUNTIME_DIR:-$HOME/tmp}"

# PATH Composition (Priority: local bin -> user bin -> runtimes -> system)
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$BUN_INSTALL/bin"
  "$NPM_DIR/bin"
  "$GO_HOME/bin"
  "$ANDROID_HOME/platform-tools"
  "$HOME/.opencode/bin"
  $path
)
export PATH

# ==============================================================================
# Aliases
# ==============================================================================
# System Maintenance
if command -v dnf >/dev/null 2>&1; then
  alias up="sudo dnf upgrade -y && flatpak update -y && update-antigravity update"
  alias clean="sudo dnf autoremove -y && sudo dnf clean all"
elif command -v apt-get >/dev/null 2>&1; then
  alias up="apt-get update && apt-get upgrade -y"
  alias clean="apt-get autoremove -y && apt-get clean"
fi
alias ports="ss -tulpn"
alias now="date +%T"
alias reload="source ~/.zshrc && echo \"✓ ~/.zshrc reloaded!\""
alias c="clear"

# Modern Coreutils (eza / bat / fd fallback)
if command -v eza >/dev/null 2>&1; then
  alias l="eza -lh --group-directories-first --icons"
  alias la="eza -A --icons"
  alias ll="eza -alF --group-directories-first --icons"
  alias l.="eza -d .* --icons"
  alias lt="eza -lhS --group-directories-first --icons"
  alias tree="eza -T --group-directories-first --icons"
else
  alias l="ls -lh"
  alias la="ls -A"
  alias ll="ls -alF"
fi
alias count="fd --type f . | wc -l"

# Memory Optimization for Mobile / PRoot / Resource-Constrained Environments
if [[ -n "${PROOT_TMP_DIR:-}" || -d "/data/data/com.termux" || ( "$(uname -m)" == "aarch64" && ! -d "/sys/class/dmi" ) ]]; then
  export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=512}"
fi

# Git
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias gd="git diff"
alias gl="git log --oneline --graph --decorate"
alias lg="lazygit"
alias kdiff="kitty +kitten diff"

# Ecosystem & Workstation
alias repos-sync="$HOME/Projects/_scheduled_jobs/sync_git_repos.sh"
alias ts="tailscale"
alias ts-toggle="$HOME/.config/scripts/tailscale-toggle.sh"
alias ts-menu="$HOME/.config/scripts/tailscale-menu.sh"

# Global Pipes (e.g. ps aux G python, cat data.json J)
alias -g G="| rg"
alias -g J="| jq"
alias -g F="| fzf"
alias -g L="| less"

# ==============================================================================
# Custom Functions
# ==============================================================================
# Project Switcher (fuzzy jump into ~/Projects)
pj() {
  local target
  if [[ -n "$1" ]]; then
    target=$(fd --max-depth 1 --type d "$1" ~/Projects | head -n 1)
  else
    target=$(fd --max-depth 1 --type d . ~/Projects | sed "s|^$HOME/Projects/||" | grep -v "^$" | fzf --prompt "🚀 Switch Project > " --preview "eza -lh --group-directories-first --icons ~/Projects/{}")
    [[ -n "$target" ]] && target="$HOME/Projects/$target"
  fi
  if [[ -d "$target" ]]; then
    cd "$target"
    eza -lh --group-directories-first --icons
  fi
}

# Quick Note / Daily Journal in digital-graveyard
note() {
  local blog_dir="${BLOG_PATH:-$HOME/Projects/digital-graveyard/content}"
  local today=$(date +%Y-%m-%d)
  local note_file="$blog_dir/${today}.md"

  mkdir -p "$blog_dir"
  if [[ ! -f "$note_file" ]]; then
    cat <<EOF > "$note_file"
---
title: "$today"
date: $(date -Iseconds)
tags: [journal]
publish_external: false
---

EOF
  fi

  if [[ $# -gt 0 ]]; then
    echo "- [$(date +%H:%M)] $*" >> "$note_file"
    echo "Saved to $note_file"
  else
    ${EDITOR:-nano} "$note_file"
  fi
}

# iERP Event Logging and CRM Helper
event() {
  if [[ $# -eq 0 ]]; then
    uv --directory ~/Projects/ierp run ierp list --limit 10
  elif [[ "$1" == "add" ]]; then
    shift
    uv --directory ~/Projects/ierp run ierp insert "$@"
  else
    uv --directory ~/Projects/ierp run ierp "$@"
  fi
}

# Search file contents with ripgrep + bat + fzf
fzf-text() {
  rg --line-number --no-heading . "$1" | fzf --preview "bat --color=always --line-range :500 {1}" | awk -F: "{print \$1}"
}

# Interactive Process Kill via fzf
fkill() {
  local pid=$(ps -ef | sed 1d | fzf -m | awk "{print \$2}")
  if [[ -n "$pid" ]]; then
    echo "$pid" | xargs kill -${1:-9}
  fi
}

# Git Identity Switchers
gci() {
  git config --local user.email "muhammad.ichsanul19@gmail.com"
  git config --local user.name "Amal"
}

git_laataiasu() {
  git config --local user.email "ichsanamal19@gmail.com"
  git config --local user.name "laataiasu"
}

# Remote Mobile Auto-Attach (Zellij)
if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$ZELLIJ" ]]; then
  zellij attach -c main
fi
