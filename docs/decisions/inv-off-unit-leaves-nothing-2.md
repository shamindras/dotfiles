---
id: inv-off-unit-leaves-nothing-2
type: invariant
date: 2026-11-11
status: accepted
supersedes: inv-off-unit-leaves-nothing
enforced_from: N2
verify: python3 scripts/test/manifest_test.py RenderTest.test_off_unit_leaves_no_package_link_step_or_binding
---

# An off unit leaves nothing behind

A unit that is off for a profile contributes no package, link, setup step or leader binding to that profile. Replaces
[the pending note](inv-off-unit-leaves-nothing.md) now that the resolver exists to test it.
