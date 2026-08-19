---
description: Use this workflow to permanently remove sensitive information (like files or API keys or wallet addresses) from the entire Git repository history.
---

## Git Purge Workflow

### 1. Pre-Purge Context

You must store the remote URL and the current branch name before `filter-repo` wipes the local config.

```bash
# Capture and store these
REMOTE_URL=$(git remote get-url origin)
CURRENT_BRANCH=$(git branch --show-current)

```

### 2. Purge Sensitive Data (String or File)

Choose the command based on what needs to be removed.

**To remove a specific file across all history:**

```bash
git filter-repo --force --path path/to/secret_file.txt --invert-paths

```

**To remove a sensitive string across all files:**

```bash
git filter-repo --force --replace-text <(echo "SECRET_STRING==>REPLACEMENT")

```

**To do both in one pass (Most Efficient):**

```bash
git filter-repo --force \
  --path path/to/secret_file.txt --invert-paths \
  --replace-text <(echo "SECRET_STRING==>REPLACEMENT")

```

### 3. Restore & Push

Re-link the origin and push everything. The `-u` flag ensures the current branch is re-tracked immediately.

```bash
# Re-add the remote using the captured URL
git remote add origin "$REMOTE_URL"

# Force push everything and re-link the current branch upstream
git push origin --force --all --set-upstream

```

---

### **AI Execution Checklist**

1. **Check for `git-filter-repo`:** If missing, install via `pip install git-filter-repo`.
2. **Local GC:** Run `git gc --prune=now --aggressive` locally after the push to ensure the data is physically gone from the agent's disk.