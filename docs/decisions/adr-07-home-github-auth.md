---
id: adr-07-home-github-auth
type: adr
date: 2026-11-10
status: accepted
supersedes: none
---

# Home GitHub auth: fresh key per Mac

Each home Mac gets a fresh SSH key, made and registered by an idempotent auth step (`scripts/setup/setup-github-auth`).
Nothing before that step needs a key: see [bootstrap needs no SSH key](inv-bootstrap-no-ssh-key.md).
