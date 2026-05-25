# Multiple Git Accounts With SSH

Create one SSH key per account:

```bash
ssh-keygen -t ed25519 -C "personal@example.com" -f ~/.ssh/id_ed25519_personal
ssh-keygen -t ed25519 -C "work@example.com" -f ~/.ssh/id_ed25519_work
```

Add the public keys to the matching Git provider accounts:

```bash
cat ~/.ssh/id_ed25519_personal.pub
cat ~/.ssh/id_ed25519_work.pub
```

Configure host aliases in `~/.ssh/config`:

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

Clone using the alias so SSH picks the right key:

```bash
git clone git@github-personal:username/repo.git
git clone git@github-work:company/repo.git
```

Set repository-local identity after cloning:

```bash
git config user.name "Personal Name"
git config user.email "personal@example.com"

git config user.name "Work Name"
git config user.email "work@example.com"
```

Keep real emails, names, key names, and private repo URLs in `~/.secrets`, `~/.ssh/config`, or the private repo.
