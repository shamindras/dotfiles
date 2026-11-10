---
id: adr-12-testing
type: adr
date: 2026-11-10
status: accepted
supersedes: none
---

# Testing in three layers, no VM

Layer 1 is static checks. Layer 2 is a dry run into a throwaway HOME. Layer 3 is a real bootstrap on GitHub macOS
runners. No VM. The harness reports [expected failures](vocab-expected-fail.md) explicitly.
