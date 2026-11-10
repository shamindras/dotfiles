---
id: inv-no-profile-branches
type: invariant
date: 2026-11-10
status: accepted
supersedes: none
enforced_from: N1
verify: ! git grep -nIiE '(profile)[^=]*(==|!=|=~)[^a-z]*(home|work)([^a-z]|$)' -- bootstrap install scripts config ':!*.md'
---

# No file branches on the profile name

Profile differences are values in the profile, never `if work` branches in code. See
[pattern: values not branches](pattern-values-not-branches.md).
