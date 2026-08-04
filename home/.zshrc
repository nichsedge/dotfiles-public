# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="" # Disabled — using starship instead

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
source $HOME/.secrets

# Starship prompt (replaces OMZ theme)
eval "$(starship init zsh)"

# Zoxide — smart cd
eval "$(zoxide init zsh)"

# FZF — fuzzy finder
source /usr/share/fzf/key-bindings.zsh 2>/dev/null
source /usr/share/fzf/completion.zsh 2>/dev/null
# FZF style: use rg for better file search
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 60% --border --info=inline'

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# Load custom configs

# ----------------------
# Aliases
# ----------------------
alias up='sudo dnf upgrade -y'
alias clean='sudo dnf autoremove -y && sudo dnf clean all'
alias c='clear'

alias l='eza -lh --group-directories-first --icons'
alias la='eza -A --icons'
alias ll='eza -alF --group-directories-first --icons'
alias l.='eza -d .* --icons'
alias lt='eza -lhS --group-directories-first --icons'
alias tree='eza -T --group-directories-first --icons'

alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

alias now='date +%T'
alias ports='ss -tulpn'
# alias gh='history|grep'
alias count='fd --type f . | wc -l'
# alias code='code-insiders'

alias reload='source ~/.zshrc && echo ".zshrc reloaded!"'

alias sync-atc='cd /home/al/Projects/atc && git pull -q && cd ../atracker/scripts && uv run sync_db.py ../atc/atracker.db'

# ----------------------
# Environment variables
# ----------------------

# . "$HOME/.local/bin/env"

export JAVA_HOME=/usr/lib/jvm/java-25-openjdk
export GO_HOME=$HOME/bin/go
export HADOOP_HOME=$HOME/bin/hadoop-3.3.6
export SPARK_HOME=$HOME/bin/spark-3.5.3-bin-without-hadoop
export SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/yarn:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*"
# export PYTHONPATH="${SPARK_HOME}/python/:$PYTHONPATH"
# export PYTHONPATH="${SPARK_HOME}/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH"

export HIVE_HOME=$HOME/bin/apache-hive-4.0.1-bin
export SCALA_HOME=$HOME/.local/share/coursier
export BUN_INSTALL="$HOME/.bun"

export NPM_DIR="$HOME/bin/node"

# ----------------------
# PATH setup
# ----------------------
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$GO_HOME/bin:$PATH"
export PATH="$HADOOP_HOME/bin:$PATH"
export PATH="$HADOOP_HOME/sbin:$PATH"
export PATH="$SPARK_HOME/bin:$PATH"
export PATH="$SPARK_HOME/sbin:$PATH"
export PATH="$HIVE_HOME/bin:$PATH"
export PATH="$SCALA_HOME/bin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$NPM_DIR/bin:$PATH"

export PROJECT_DIR=$HOME/Projects
# export PROJECT_DATA_DIR=$PROJECT_DIR/.data
export BLOG_PATH="$PROJECT_DIR/digital-graveyard/content"

# GCP
# export GCP_CREDENTIALS="$PROJECT_DIR/creds/gcp/SA_cred_general.json"
export TF_VAR_bq_creds_file="$PROJECT_DIR/creds/gcp/bq.json"
export GCP_CREDENTIALS="$PROJECT_DIR/creds/gcp/bq.json"

export AIRFLOW_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/airflow"
export TMPDIR="${XDG_RUNTIME_DIR:-$HOME/tmp}"

# uv
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

# bun completions
[ -s "/home/al/.bun/_bun" ] && source "/home/al/.bun/_bun"

# ----------------------
# Custom functions
# ----------------------

# Fix completions for uv run.

# Git identity switchers
gci() {
  git config user.email "muhammad.ichsanul19@gmail.com"
  git config user.name "Amal"
}

git_laataiasu() {
  git config user.email "ichsanamal19@gmail.com"
  git config user.name "laataiasu"
}

# FZF helpers
# Ctrl+R: search command history (already bound by fzf)
# Ctrl+T: search files (already bound by fzf)
# Alt+C: fuzzy cd with zoxide (already bound by fzf)
# Additional: search file contents with rg + fzf
fzf-text() {
  rg --line-number --no-heading . $1 | fzf --preview 'bat --color=always --line-range :500 {1}' | awk -F: '{print $1}'
}

# gct() {
#   git config user.email "dqmops@telkomsel.co.id"
#   git config user.name "dqmops"
# }

# # Path for custom local completions
# fpath=(~/.zsh/completions $fpath)

# # Initialize completion system (usually done only once)
# autoload -U compinit
# compinit



# OpenClaw Completion
# source <(openclaw completion --shell zsh)

# opencode
export PATH=/home/al/.opencode/bin:$PATH

export PATH="/home/al/bin/flutter/bin:$PATH"

alias theme-sync='/home/al/Projects/misc/update_repos.sh'
alias sync-repos='/home/al/Projects/sync_git_repos.sh'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/al/bin/google-cloud-sdk/path.zsh.inc' ]; then . '/home/al/bin/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/al/bin/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/al/bin/google-cloud-sdk/completion.zsh.inc'; fi
