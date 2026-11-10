---
id: inv-home-parity-2
type: invariant
date: 2026-11-11
status: accepted
supersedes: inv-home-parity
enforced_from: N3
verify: scripts/test/check-parity
---

# Rendered home equals today's install

`generated/home/` has the same packages and links as the install at the baseline commit `acec184` (main before the
overhaul), apart from the agreed changes recorded in `docs/plan/home-parity.json`. Replaces
[the pending note](inv-home-parity.md).
