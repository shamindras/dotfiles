---
description: "Compare and sync a skill from a source repo. Args: <skill-path> --from <repo-path> [--dry-run] [--meta] [--universal-only] [--include-commands] [--help]"
---

Sync a skill directory between repos, preserving repo-specific content.

## 1. Parse and validate

If `--help` is present, display help text and **stop**:

```
/sync-skill — Compare and sync a skill from a source repo.

Usage:
  /sync-skill <skill-path> --from <repo-path> [flags]
  /sync-skill --meta --from <repo-path> [flags]

Flags:
  --from <path>        Source repo path (required)
  --dry-run            Report only, no changes
  --meta               Sync the sync-skill itself
  --universal-only     Skip repo-specific zone diffs
  --include-commands   Also compare .claude/commands/ symlinks
  --help               Show this help

Examples:
  /sync-skill git --from ~/dotfiles
  /sync-skill git --from ~/dotfiles --dry-run
  /sync-skill --meta --from ~/dotfiles
```

Extract `<skill-path>` and `--from <path>` from `$ARGUMENTS`.

If `--meta`: set skill-path to `.claude/skills/meta/` and also check
`.claude/commands/sync-skill.md`. `<skill-path>` argument not required.

Validate source path exists: `ls <from>/.claude/skills/<skill-path>/`.
If missing → error and stop.

Check if target exists: `ls .claude/skills/<skill-path>/`.
If missing → **new skill bootstrap** (Step 1a).

### Step 1a: New skill bootstrap

When the source has a skill that doesn't exist in the target:

1. Announce: "Skill `<skill-path>` exists in source but not in this repo."
2. List source files with brief description of each.
3. Classify each file:
   - **Universal** (no `<!-- REPO-SPECIFIC -->` markers): copy verbatim.
   - **Parameterized** (has markers): copy with repo-specific zones replaced
     by scaffold prompts.
4. Generate bootstrap plan showing:
   - Which files copied verbatim (universal)
   - Which files scaffolded (parameterized) — listing each zone
   - What symlinks to create in `.claude/commands/`
   - What `CLAUDE.md` entries to add
5. For each scaffolded zone, describe what the source has and what the target
   should provide. Example:
   ```
   workflow.md — REPO-SPECIFIC zones to customize:

   1. scopes: Source has tool-based scopes (nvim, tmux, brew...).
      → Define scopes for YOUR repo's content areas.
      → Look at your directory structure to decide groupings.

   2. examples: Source has dotfiles commit examples.
      → Write 3-5 commit examples reflecting YOUR repo's patterns.
      → Run `git log --oneline -20` for inspiration.
   ```
6. Wait for approval before creating any files.
7. After approval: create directory, copy/scaffold files, create symlinks.
8. Post-bootstrap: prompt user to fill TODO placeholders. Offer: "Want me
   to analyze your repo and suggest repo-specific content for each zone?"

## 2. Discover files

Use Glob on both directories to list all files recursively:
- Source: `<from>/.claude/skills/<skill-path>/**/*`
- Target: `.claude/skills/<skill-path>/**/*`

Classify by relative path:
- **Both**: exists in source and target
- **Source-only**: exists in source but not target
- **Target-only**: exists in target but not source

If `--include-commands`: also compare `.claude/commands/` symlinks pointing
into the skill directory.

## 3. Compare files in both repos

For each file present in both:

### 3a. Read both files

### 3b. Check for `<!-- REPO-SPECIFIC: name -->` markers

**If markers exist:**
- Parse into segments: alternating "universal" and "repo-specific" blocks.
- Universal = text outside marker pairs.
- Repo-specific = text between `<!-- REPO-SPECIFIC: ... -->` /
  `<!-- END REPO-SPECIFIC -->` pairs (inclusive).
- Compare only universal blocks between source and target.
- Identical → "in sync".
- Different → "universal drift detected". Show diff of universal blocks only.
- Always report repo-specific zones as "intentionally different (N zones)".
- If `--universal-only`: skip repo-specific zone reporting entirely.

**If no markers:**
- Diff the two files.
- Identical → "in sync".
- Different → flag as drift. Show full diff.
- Look for patterns suggesting repo-specific content (scope tables, path
  examples, tool names). Warn: "This file has no REPO-SPECIFIC markers.
  Consider adding them if some content should differ."

**Unmatched markers**: If open/close tags don't match, warn and fall back
to full-file diff.

## 4. Generate sync report

```
========================================
Skill Sync Report: <skill-path>
========================================
Source: <from-path>
Target: <current-repo-path>
Date:   <today>

--- Files in sync (universal) ---
  commands/commit.md           identical
  flags.md                     identical
  land.md                      identical

--- Files with repo-specific zones ---
  workflow.md                  universal: IN SYNC | repo-specific: 6 zones (expected)
  emoji.md                     universal: IN SYNC | repo-specific: 1 zone (expected)

--- Universal drift detected ---
  (none)
  OR:
  workflow.md  lines 18-24:
    Source adds: "**REQUIRED**: When presenting..."
    Target has:  "When presenting a plan..."

--- Source-only files ---
  (none)  OR:
  new-feature.md               exists in source, not in target

--- Target-only files ---
  blog-overrides.md            exists in target only (repo-specific, expected)

========================================
Summary: 5 files checked, 3 identical, 2 repo-specific OK, 0 drift
========================================
```

If `--dry-run`: stop here. Do not generate a sync plan.

## 5. Generate sync plan

**Default: plan-first.** Generate a complete sync plan and wait for user
approval before making any changes.

```
========================================
Sync Plan: <skill-path>
========================================
Source: <from-path>
Target: <current-repo-path>

Actions (in order):

1. UPDATE universal sections in workflow.md
   - Lines 18-24: "Feature Branches in Plans" → stronger REQUIRED language
   - Repo-specific zones (6): PRESERVED, no changes

2. COPY new file: guardrails.md
   - Universal file (no markers), copy verbatim from source

3. SKIP blog-overrides.md
   - Target-only file (repo-specific, no action needed)

4. NO ACTION needed for: commit.md, flags.md, land.md, emoji.md
   - Already in sync

========================================
Approve this plan? [approve / modify / abort]
========================================
```

User responses:
- **approve**: Execute all actions.
- **modify**: User specifies changes. Re-present plan.
- **abort**: Stop without changes.

## 6. Execute approved plan

**UPDATE (universal drift):**
- Read target file.
- For each universal block, replace with source's version.
- Repo-specific zones (between markers) left untouched.
- Write result.

**COPY (source-only, no markers):**
- Copy verbatim from source to target.

**COPY-AND-SCAFFOLD (source-only, with markers):**
- Copy from source.
- Replace repo-specific zone contents with:
  ```
  <!-- REPO-SPECIFIC: <name> -->
  <!-- TODO: Define <name> for this repo. See source for format. -->
  <!-- END REPO-SPECIFIC -->
  ```
- Present scaffolded file to user, ask them to fill in zones.

**SKIP:**
- No action.

## 7. Verify

After all changes applied:
- Re-run comparison (steps 2-4) and show updated report.
- Show `git diff --stat` of modified files.
- If COPY-AND-SCAFFOLD actions taken, remind user to fill TODO placeholders.
- Suggest: "Review changes, then `/commit` to save."

## First-time sync: no markers yet

When syncing to a repo that has skill files but no REPO-SPECIFIC markers:

**Detection**: Step 3b finds no markers in either copy. Full diff computed.

**Classification**: Differences classified as:
- **Likely repo-specific**: Scope tables, branch name examples, path examples,
  commit examples, type description wording.
- **Likely universal drift**: Structural changes, new sections, rule changes.

**Recommendation**: The sync plan proposes:
1. Add REPO-SPECIFIC markers to source (if not already there).
2. Add matching markers to target, wrapping target's existing content.
3. Then compare universal sections.

## Self-sync

`/sync-skill --meta --from <path>` compares the sync-skill's own files.
`sync-skill.md` has no REPO-SPECIFIC markers (fully universal), so step 3b
treats it as a plain diff.

**Recommendation**: When syncing multiple skills, self-sync first:
```
/sync-skill --meta --from ~/dotfiles
/sync-skill git --from ~/dotfiles
```
