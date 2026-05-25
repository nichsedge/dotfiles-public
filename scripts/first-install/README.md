# First Install Scripts

Primary Fedora GNOME bootstrap:

```bash
./bootstrap.sh --profile fedora-gnome
```

Secondary distro scripts:

```bash
./scripts/first-install/ubuntu.sh --dry-run
./scripts/first-install/arch.sh --dry-run
```

Shared user-level tools:

```bash
./scripts/tools/install-dev-tools.sh --dry-run
```

Private credentials, cloud files, machine-specific project aliases, and personal docs are layered later from the private repo.
