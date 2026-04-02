# Repo Overrides — plan-prompt-drafter

Context read at invocation time by `/plan-prompt-drafter`.
All universal prompt-drafting rules live in the skill file itself.
This file contains only repo-specific additions.

<!-- REPO-SPECIFIC: repo-context -->
## CLAUDE.md Pointers

Read `CLAUDE.md` at the repo root. Pay particular attention to:

- § Supported Applications — current tool stack
- § Shared conventions for tool configs — Lua/shell/theme/keybinding rules
- § Design principles — idempotency and reproducibility constraints
- § Version verification for tool configs — must verify before writing configs
- § Plan mode — interview-style, section-by-section process
- § Branch-First Rule — every prompt should reference branch workflow
- § Tool-specific CLAUDE.md files — update `config/<tool>/CLAUDE.md` with changes
- § Tool reload after config changes — include reload steps when applicable

## Repo-Specific Prompt Additions

- When a prompt involves config changes, include before/after comparison tables
- When a prompt touches tool configs, add a version verification research step
  (check installed version, verify against current docs, validate after writing)
- When a prompt touches reloadable tools (aerospace, borders, sketchybar, yazi,
  leader-key), include the reload command in the process section

## Skill Pointers

- Git workflow: see `.claude/skills/git/workflow.md` for commit types, scopes,
  branch naming, and conventions. Drafted prompts must respect these; do not
  restate them, just point to the skill.

## Out-of-Scope Handling

Do not assume what is out of scope. Survey the user interactively
(one question at a time, checkbox format per step 5a in the skill)
about what should be deferred, then place those items in a "Future
Considerations" section explicitly marked as out of scope for the
current session.
<!-- END REPO-SPECIFIC -->
