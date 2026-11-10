---
id: inv-bootstrap-no-ssh-key
type: invariant
date: 2026-11-10
status: accepted
supersedes: none
enforced_from: N7
verify: ! grep -nE 'git@github\.com|ssh://' bootstrap install .gitmodules
---

# Bootstrap needs no SSH key

Nothing that runs before the auth step uses an SSH URL. Honours [home auth](adr-07-home-github-auth.md).
