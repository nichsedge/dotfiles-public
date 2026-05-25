# PostgreSQL Restore Notes

Reference checklist for restoring a local PostgreSQL instance. Keep dump files and passwords outside the public repo.

```bash
sudo -iu postgres
initdb -E UTF8 -D /var/lib/postgres/data/
exit

sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo -u postgres psql
```

Restore a dump from a private backup path:

```bash
sudo -u postgres pg_restore -d postgres /path/to/private/backup.dump
```
