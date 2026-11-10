---
id: adr-06-git-identity
type: adr
date: 2026-11-10
status: accepted
supersedes: none
---

# Git identity is untracked

The tracked git config holds no identity. Name, email and signing key are set on day one in the untracked
`~/.config/git/config.local`.
