---
id: adr-15-keeping-fresh
type: adr
date: 2026-11-10
status: accepted
supersedes: none
---

# Weekly update PR and mise scoreboard

A weekly GitHub job opens one update PR, auto-merged only when every check is green. It also records a mise scoreboard.
Neither touches the install path; see [engine](adr-04-engine.md).
