---
id: inv-no-link-into-cloudstorage
type: invariant
date: 2026-11-10
status: accepted
supersedes: none
enforced_from: N16
verify: ! pwd -P | grep -q CloudStorage
---

# No link resolves into CloudStorage

No link the install creates resolves into `~/Library/CloudStorage`. The repo clone itself must sit outside it. Honours
[no repos in Dropbox](adr-03-no-git-in-dropbox.md).
