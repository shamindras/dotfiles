---
id: adr-05-work-modules
type: adr
date: 2026-11-10
status: accepted
supersedes: none
---

# Work modules on day one

The work profile turns on core, git, editor, terminal, desktop and data-science on day one. A unit whose precheck fails
(no sudo, policy block, missing grant) is skipped with a reason, never fatal.
