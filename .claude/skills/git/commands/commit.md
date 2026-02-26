---
description: "Commit changes. Flags: --staged, --all, --draft, --amend, --all-and-push, --no-split, --emoji, --land, --land-main, --help"
---

Follow these steps to commit the user's changes. Read `.claude/skills/git/workflow.md` first for conventions.

## 1. Parse flags

Scan `$ARGUMENTS` for the following flags:

| Flag | Effect |
|------|--------|
| `--staged` | Only commit what's already staged |
| `--all` | Stage all tracked changes, then commit |
| `--draft` | Dry run — show preview, stop before committing |
| `--amend` | Amend previous commit |
| `--all-and-push` | Stage all, commit, push (no confirmation) |
| `--no-split` | Skip scope-based split analysis |
| `--emoji` | Prefix description with type-mapped emoji |
| `--land` | After committing: push, PR, merge, clean up |
| `--land-main` | Shortcut for `--land` targeting `main` |
| `--help` | List flags and stop |

**Mutual exclusions** — error if combined:

- `--staged` + `--all`
- `--staged` + `--all-and-push`
- `--amend` + `--all-and-push`
- `--draft` + `--all-and-push`
- `--land` + `--draft`
- `--land` + `--amend`
- `--land` + `--all-and-push`
- `--land` + `--land-main`
- `--land-main` + `--draft`
- `--land-main` + `--amend`
- `--land-main` + `--all-and-push`

If an unknown `--flag` is present, warn the user and list valid flags.

**Load subskills based on active flags:**
- Any of `--staged`/`--all`/`--all-and-push`/`--amend`/`--draft`:
  read `.claude/skills/git/flags.md`
- `--emoji`: read `.claude/skills/git/emoji.md`
- `--land` or `--land-main`: read `.claude/skills/git/land.md`
- `--help`: display flag table and **stop**
- `--no-split`: handled inline (skip step 5)

Apply overrides from subskill files to the relevant steps below.

## 2. Check branch

Run `git branch --show-current`.

If detached HEAD, warn and **stop**.

### On a feature branch
Proceed without interruption.

### On `main` — assess before deciding
1. Run `git status --short` and `git diff --stat` to gauge scope.
2. **Trivial** (single-file typo, one-line tweak, docs-only): note the
   branch, proceed — "On `main`. Small fix — proceeding."
3. **Non-trivial**: proactively propose a feature branch before staging —
   "On `main` and these changes look non-trivial. Suggest creating
   `<type>/<short-desc>` first. Create it, or proceed on `main`?"
4. User explicitly said commit on `main` → skip suggestion.
5. `--all-and-push` on `main` → pause and confirm. Never auto-push.
6. `--land`/`--land-main` on `main` → hard error, **stop**.

### Non-trivial heuristic
Any of: 3+ files, new file/directory, diff > ~30 lines, multiple scopes,
or type would be `feat`/`refactor`. When in doubt, propose the branch.

## 3. Determine what to commit

Run `git status --short` and `git diff --staged --stat`. If nothing is
staged, show status and ask what to stage.

**Flag overrides**: see `flags.md` §--staged, §--all, §--all-and-push, §--amend.

## 4. Diff preview

Always show a diff preview before drafting the commit message.

- Run `git diff --staged --stat` (or `git diff --stat` for unstaged files being considered).
- Then show actual diff content (`git diff --staged` or `git diff -- <files>`).
- If the diff exceeds ~200 lines, truncate and note that it was truncated.
- For massive diffs (1000+ lines of stat output), show `--stat` only and offer the full diff on request.

## 5. Smart split analysis (scope-based)

**Skip if `--no-split` is set.**

**Default: always split by scope.** Only consolidate into a single commit
when the user explicitly requests it (via `--no-split` or direct instruction).
Never preemptively suggest combining scopes.

Apply the splitting rules from the "Commit Splitting" section in
`.claude/skills/git/workflow.md`. Use the scopes defined there to identify,
group, and present the proposed commits to the user before proceeding.

## 6. Draft message

For each commit (or single commit), draft a conventional commit message:

- Use the type selection heuristic from `workflow.md`.
- Format: `<type>(<scope>): <description>` (≤72 chars, imperative, lowercase, no period).
- Add a body if the change needs explanation (wrap at 79 chars).

**Flag overrides**: see `flags.md` §--amend; see `emoji.md` §Step override.

## 7. Confirm with user

Show the proposed commit message and files to be staged/committed.
**Wait for explicit user approval before committing.**

**Flag overrides**: see `flags.md` §--all-and-push, §--draft.

## 8. Commit

Stage the discussed/approved files by name, then commit using a HEREDOC
for the message to preserve formatting.

**Flag overrides**: see `flags.md` §--staged, §--all, §--all-and-push, §--amend.

## 9. Post-commit

- Run `git log --oneline -3` to confirm the result.
- If `--land` or `--land-main` is active, proceed to land workflow (see `land.md`).

**Flag overrides**: see `flags.md` §--all-and-push; see `land.md`.

## Important

- Never force-push or push without being asked (except `--all-and-push`).
- Never amend previous commits unless `--amend` is used or explicitly requested.
- Always show the proposed message before committing (except `--all-and-push`).
