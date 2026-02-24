# Flag Overrides

Step overrides for `--staged`, `--all`, `--all-and-push`, `--amend`,
and `--draft`. Apply these to the corresponding steps in `commit.md`.

## `--staged`

- **Step 3**: Use only what's in the index. If nothing staged, warn and stop.
- **Step 8**: No new staging — commit the index as-is.

## `--all`

- **Step 3**: All tracked modified files. Run `git status --short`.
- **Step 8**: Stage tracked files by name (`git add <file>...` — never
  `git add -A`).

## `--all-and-push`

- **Step 3**: Same as `--all`.
- **Step 7**: Skip confirmation (but `main` branch protection from step 2
  still applies).
- **Step 8**: Same as `--all`.
- **Step 9**: Also run `git push` (or `git push -u origin <branch>` if no
  upstream). Never force-push.

## `--amend`

- **Step 3**: Show previous commit (`git log -1 --format="%h %s"`) plus any
  newly staged changes.
- **Step 6**: Show previous commit message for reference alongside new draft.
- **Step 8**: Use `git commit --amend`.

## `--draft`

- **Step 7**: Show drafted message and stop. Print: "This is a draft — no
  commit was made." Do not proceed to step 8.
