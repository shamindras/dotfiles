---
id: inv-bootstrap-no-dropbox
type: invariant
date: 2026-11-10
status: accepted
supersedes: none
enforced_from: N5
verify: ! grep -n -i dropbox bootstrap install
---

# Bootstrap needs no Dropbox

`./bootstrap` and `./install` never mention or wait for Dropbox. Honours
[no repos in Dropbox](adr-03-no-git-in-dropbox.md).
