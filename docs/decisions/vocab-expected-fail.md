---
id: vocab-expected-fail
type: vocab
date: 2026-11-10
status: accepted
supersedes: none
---

# Expected failure (XFAIL)

A check that fails because the node that fixes it has not landed is reported as XFAIL with that node's id. Once the
node's commit (trailer `Node: <id>`) is in history, the same failure is a FAIL. A check that passes early is XPASS:
reported, not a failure. Nothing is skipped silently.
