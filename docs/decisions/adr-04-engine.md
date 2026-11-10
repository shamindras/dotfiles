---
id: adr-04-engine
type: adr
date: 2026-11-10
status: accepted
supersedes: none
---

# Homebrew, dotbot, manifest

Homebrew is the only package manager on the Macs and dotbot is the only linker. One hand-maintained `manifest.json` plus
a resolver generates everything else. mise is not used on the Macs; it only runs in the
[weekly scoreboard](adr-15-keeping-fresh.md).
