[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"
export UV_LINK_MODE="${UV_LINK_MODE:-copy}"
