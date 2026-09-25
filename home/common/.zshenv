[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$HOME/go/bin:$PATH"
export UV_LINK_MODE="${UV_LINK_MODE:-copy}"
