---
id: adr-09-no-brewfile-dump
type: adr
date: 2026-11-10
status: accepted
supersedes: none
---

# No Brewfile auto-dump

`brew-update` no longer dumps a Brewfile. It reports drift against the manifest and changes nothing.
