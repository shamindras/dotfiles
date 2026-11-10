---
id: pattern-ratchet-loop
type: pattern
date: 2026-11-10
status: accepted
supersedes: none
---

# Ratchet loop per node

Each plan node runs propose, apply, verify, then keeps the commit or resets to the last kept one, up to its try budget.
Every try is a line in `docs/plan/trials.jsonl`. A verify command is never weakened to pass.
