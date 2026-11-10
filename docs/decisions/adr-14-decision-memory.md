---
id: adr-14-decision-memory
type: adr
date: 2026-11-10
status: accepted
supersedes: none
---

# Decisions live in docs/decisions

Decisions and invariants are small linked Markdown notes in `docs/decisions/`, one fact per file. Notes are append-only:
a change is a new note whose `supersedes` names the old one.
