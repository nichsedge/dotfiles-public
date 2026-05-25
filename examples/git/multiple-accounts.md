# Multiple Git Accounts With SSH

Create one key per account:

```bash
ssh-keygen -t ed25519 -C "personal@example.com" -f ~/.ssh/id_ed25519_personal
ssh-keygen -t ed25519 -C "work@example.com" -f ~/.ssh/id_ed25519_work
```

Use SSH host aliases in `~/.ssh/config`:

```sshconfig
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes

Host github-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
  IdentitiesOnly yes
```

Clone with the alias:

```bash
git clone git@github-personal:username/repo.git
git clone git@github-work:company/repo.git
```

Keep real emails, names, and key paths in the private repo or `~/.secrets`.
