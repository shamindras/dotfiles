---
id: adr-03-no-git-in-dropbox
type: adr
date: 2026-11-10
status: accepted
supersedes: none
---

# No git repos in Dropbox

Dropbox holds data only (notes, books, media), and only on the home profile. No git repository lives in Dropbox.
Enforced by [bootstrap needs no Dropbox](inv-bootstrap-no-dropbox.md) and
[no link into CloudStorage](inv-no-link-into-cloudstorage.md).
