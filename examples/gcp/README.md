# GCP Template

Do not commit service-account JSON, OAuth tokens, or credential files.

Recommended private layout:

```text
~/Projects/creds/gcp/
  service-account.example-name.json
  oauth-client.example-name.json
  token.example-name.json
```

Expose paths through `~/.secrets` or `~/.zshrc.local`:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/Projects/creds/gcp/service-account.example-name.json"
export TF_VAR_bq_creds_file="$HOME/Projects/creds/gcp/service-account.example-name.json"
```
