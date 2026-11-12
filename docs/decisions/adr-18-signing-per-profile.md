---
id: adr-18-signing-per-profile
type: adr
date: 2026-11-12
status: accepted
supersedes: none
---

# Commit signing is a profile setting

`git_signing` in each profile decides whether commits and tags are signed: on at home, off at work until Xero's policy
is known on day one. The tracked git config no longer forces signing, so a work Mac without a key can still commit.
Refines [git identity per profile](adr-06-git-identity-2.md).
