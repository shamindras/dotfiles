---
id: adr-19-credential-helper-per-profile
type: adr
date: 2026-11-12
status: accepted
supersedes: none
---

# gh as git's credential helper is a profile setting

`git_gh_credential_helper` decides whether git asks gh for github.com HTTPS credentials: on at home, off at work until
Xero's GitHub setup is known, so a work account's gh login never silently signs pushes to personal repos. The tracked
git config sets no helper. Cloning and pulling public repos need no credentials either way. Refines
[git identity per profile](adr-06-git-identity-2.md).
