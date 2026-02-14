---
description: "Commit changes. Flags: --staged, --all, --draft, --amend, --all-and-push, --no-split, --help"
---

Follow these steps to commit the user's changes. Read `.claude/skills/git/workflow.md` first for conventions.

## 1. Parse flags

Scan `$ARGUMENTS` for the following flags:

| Flag | Effect |
|------|--------|
| `--staged` | Only commit what's already staged; skip staging questions |
| `--all` | Stage all tracked changes, then commit |
| `--draft` | Dry run — draft message, show preview, stop before committing |
| `--amend` | Amend previous commit instead of creating a new one |
| `--all-and-push` | Stage all, commit, push. No confirmation. Pause if on `main`. |
| `--no-split` | Skip smart grouping/split analysis |
| `--help` | List all flags and stop |

**Mutual exclusions** — error if combined:

- `--staged` + `--all`
- `--staged` + `--all-and-push`
- `--amend` + `--all-and-push`
- `--draft` + `--all-and-push`

If an unknown `--flag` is present, warn the user and list valid flags.

If `--help` is present, display the flag table above and **stop** — do not continue the workflow.

## 2. Check branch

Run `git branch --show-current`.

- If on `main`, warn the user and offer to create a feature branch (`<type>/<short-desc>`).
- If the user explicitly said to commit on `main`, skip branching but follow all commit conventions.
- **`--all-and-push` on `main`**: pause and ask for confirmation before proceeding. Never auto-push to `main`.

## 3. Determine what to commit

| Flag | Behavior |
|------|----------|
| `--staged` | Use only what's already in the index. If nothing is staged, warn and stop. |
| `--all` / `--all-and-push` | All tracked, modified files. Run `git status --short` to identify them. |
| `--amend` | Show the previous commit (`git log -1 --format="%h %s"`) plus any newly staged changes. |
| _(default)_ | Run `git status --short` and `git diff --staged --stat`. If nothing is staged, show status and ask what to stage. |

## 4. Diff preview

Always show a diff preview before drafting the commit message.

- Run `git diff --staged --stat` (or `git diff --stat` for unstaged files being considered).
- Then show actual diff content (`git diff --staged` or `git diff -- <files>`).
- If the diff exceeds ~200 lines, truncate and note that it was truncated.
- For massive diffs (1000+ lines of stat output), show `--stat` only and offer the full diff on request.

## 5. Smart split analysis (scope-based)

**Skip this step if `--no-split` is set.**

### Dotfiles convention: split by scope (default)

1. **Identify scopes for all changes:**
   - For tool-specific files (e.g., `config/nvim/*`), scope is obvious: `(nvim)`
   - For shared files (Brewfile, install.conf.yaml, CLAUDE.md, justfile), analyze each hunk to determine which tool/scope it relates to
   - For multi-tool hunks, either split the hunk or ask user which scope to use

2. **Group changes by scope:**
   - Organize all hunks (across all files) by their identified scope
   - Each scope becomes a proposed commit

3. **Present grouping to user:**
   ```
   Proposed commits:

   1. feat(nvim): add telescope fuzzy finder
      - config/brew/Brewfile (telescope dependencies)
      - config/nvim/lua/plugins/telescope.lua (new file)
      - install.conf.yaml (nvim setup changes)

   2. chore(brew): update ripgrep to latest
      - config/brew/Brewfile (version bump)
   ```

4. **Exceptions** — keep together only if:
   - Changes are truly atomic (adding new tool = Brewfile + config + install step)
   - User explicitly requests combining scopes
   - Using `--no-split` flag

5. **Verify with user before proceeding**

## 6. Draft message

For each commit (or single commit), draft a conventional commit message:

- Use the type selection heuristic from `workflow.md`.
- Format: `<type>(<scope>): <description>` (≤72 chars, imperative, lowercase, no period).
- Add a body if the change needs explanation (wrap at 79 chars).
- **`--amend`**: show the previous commit message for reference alongside the new draft.

## 7. Confirm with user

- **`--all-and-push`**: skip confirmation (but `main` branch protection from step 2 still applies).
- **`--draft`**: show the drafted message and stop here. Print: "This is a draft — no commit was made."
- **All others**: show the proposed commit message and files to be staged/committed. **Wait for explicit user approval before committing.**

## 8. Commit

| Flag | Staging behavior |
|------|-----------------|
| `--staged` | No new staging — commit the index as-is |
| `--all` / `--all-and-push` | Stage tracked files by name (`git add <file> ...` — never `git add -A`) |
| `--amend` | Use `git commit --amend` |
| _(default)_ | Stage the discussed/approved files by name |

Commit using a HEREDOC for the message to preserve formatting.

## 9. Post-commit

- Run `git log --oneline -3` to confirm the result.
- **`--all-and-push`**: also run `git push` (or `git push -u origin <branch>` if no upstream is set). Never force-push.

## Important

- Never force-push or push without being asked (except `--all-and-push`).
- Never amend previous commits unless `--amend` is used or explicitly requested.
- Always show the proposed message before committing (except `--all-and-push`).
