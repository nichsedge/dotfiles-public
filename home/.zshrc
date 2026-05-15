# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

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
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"

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
alias up='sudo apt update && sudo apt upgrade -y'
alias clean='sudo apt autoremove && sudo apt clean'
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
# alias gh='history|grep'
alias count='find . -type f | wc -l'
# alias code='code-insiders'

alias reload='source ~/.zshrc && echo ".zshrc reloaded!"'
alias agy='antigravity'

alias sync-atc='cd /home/al/Projects/atc && git pull -q && cd ../atracker && uv run sync_db.py ../atc/atracker.db'

# ----------------------
# Environment variables
# ----------------------

# . "$HOME/.local/bin/env"

export JAVA_HOME=/usr/lib/jvm/default-java
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
# export PORTFOLIO_DATA_DIR="$PROJECT_DIR/portfolio_integration/data"
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
  git config user.email "${GIT_EMAIL_PERSONAL:-personal@example.com}"
  git config user.name "${GIT_NAME_PERSONAL:-Personal Name}"
}

# gcn() {
#   git config user.email "${GIT_EMAIL_ALT:-alt@example.com}"
#   git config user.name "${GIT_NAME_ALT:-Alt Name}"
# }

# gct() {
#   git config user.email "${GIT_EMAIL_WORK:-work@example.com}"
#   git config user.name "${GIT_NAME_WORK:-Work Name}"
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
alias theme-sync='/home/al/Projects/misc/update_repos.sh'
alias sync-repos='/home/al/Projects/sync_git_repos.sh'

# Local machine-only overrides (not tracked)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
