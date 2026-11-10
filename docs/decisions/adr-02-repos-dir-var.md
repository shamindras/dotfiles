---
id: adr-02-repos-dir-var
type: adr
date: 2026-11-10
status: accepted
supersedes: none
---

# REPOS_DIR replaces DROPBOX_REPOS_DIR

`REPOS_DIR` is the one environment variable for the repos root. It replaces `DROPBOX_REPOS_DIR`. Its value comes from
the profile, per [repos dir](adr-01-repos-dir.md).
