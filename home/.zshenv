# Keep zshenv small: it is loaded by every zsh invocation.
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

path_prepend() {
  [[ -d "$1" ]] && case ":$PATH:" in *":$1:"*) ;; *) PATH="$1:$PATH" ;; esac
}

path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
export PATH
