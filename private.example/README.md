# Private Overlay Example

The public repo expects optional private files in `$HOME`:

```text
~/.secrets       # mode 0600, env vars and identities
~/.zshrc.local   # mode 0600, machine/project aliases and paths
~/.profile.local # mode 0600, login-session paths
```

Suggested private repo layout:

```text
~/Projects/creds/
  gcp/                 # service-account and OAuth JSON files
  ssh/                 # notes only; avoid copying private keys unnecessarily
  personal/            # CV, LinkedIn exports, personal docs
  install-private.sh   # creates links or copies private local files
```

Never publish real tokens, keys, account IDs, private resumes, or cloud credential JSON.
