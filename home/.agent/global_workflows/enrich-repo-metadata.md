---
description: enrich repository metadata
---

Analyze current repo and improve GitHub discoverability/branding.

Rules:
- Inspect before editing.
- Do not invent features.
- Do not change app code.
- Use `gh`; I am already logged in.
- Be concise.
- Show plan, then execute.
- Do not commit.

Steps:
1. Inspect:
   pwd; ls -la; git remote -v; git status
   Read README, package/package metadata files, and main source folders.

2. Identify:
   purpose, tech stack, users, features, install/use flow, license, repo URL.

3. Audit GitHub:
   gh repo view --json name,description,homepageUrl,repositoryTopics,url,visibility,licenseInfo

4. Propose then apply:
   - better repo description
   - relevant GitHub topics
   - README improvements
   - safe package metadata updates

5. Validate:
   git diff
   git status
   gh repo view --json description,homepageUrl,repositoryTopics,url

Final output:
- what changed
- files edited
- GitHub metadata updated
- anything skipped
- no commit made