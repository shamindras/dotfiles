---
id: adr-17-no-recovery-guide
type: adr
date: 2026-11-11
status: accepted
supersedes: none
---

# No recovery guide in the repo

`RECOVERY.md` is deleted and no recovery guide is kept (it stays in git history). The one remaining escape hatch, SSH
from a phone then `pkill -x Hammerspoon` on the home profile, is a two-line hint in `post-install-hints`.
