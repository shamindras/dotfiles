---
id: adr-06-git-identity-2
type: adr
date: 2026-11-11
status: accepted
supersedes: adr-06-git-identity
---

# Git identity per profile; the work email stays off the repo

The tracked `config/git/config` holds no identity and no signing-key path; it includes `~/.config/dotfiles/gitconfig`
(rendered from the profile in `manifest.json`) and then `~/.config/dotfiles/gitconfig.local`. Home's name and email are
tracked in the profile. Work tracks the name only: the email is asked for once by `setup-github-auth` (or passed with
`--email`) and written to `gitconfig.local`, outside the repo, so the Xero address is never public. No hand-made file
lives inside the repo tree. The signing key is the fixed `~/.ssh/id_ed25519_github` on every Mac. The https-to-ssh
rewrite is gone; `gh` is the credential helper. Replaces [the earlier decision](adr-06-git-identity.md), which put
identity in an untracked file.
