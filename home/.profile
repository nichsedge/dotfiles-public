# Login shell setup shared by graphical sessions and POSIX shells.

if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi

path_prepend_profile() {
  [ -d "$1" ] && case ":$PATH:" in *":$1:"*) ;; *) PATH="$1:$PATH" ;; esac
}

path_prepend_profile "$HOME/bin"
path_prepend_profile "$HOME/.local/bin"
[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Machine-specific login-shell exports belong here, not in the public repo.
[ -r "$HOME/.profile.local" ] && . "$HOME/.profile.local"
export PATH
