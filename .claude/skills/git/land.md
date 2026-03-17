# Land Workflow

Executes after commit (step 9) or standalone if no changes to commit.
Requires a feature branch — refuses from `main` (enforced in step 2).

If no changes were committed (clean tree with `--land`), skip steps 3–9
and begin here directly.

## 10a. Pre-flight checks

1. **Uncommitted changes**: `git status --short`. If changes remain,
   warn and ask whether to proceed or stop.
2. **Base branch**: `--land-main` → `main`. `--land` → default `main`.
3. **Fetch**: `git fetch origin <base>`.
4. **Divergence**: `git rev-list --count HEAD..origin/<base>`. If base
   has new commits, attempt `git rebase origin/<base>`. On conflict:
   `git rebase --abort`, report files, **stop**.
5. **Up-to-date**: if `git diff origin/<base>...HEAD` is empty →
   "nothing to land", **stop**.

## 10b. Push

- `git push -u origin <branch>`.
- If rejected → report and **stop**. Never force-push.

## 10c. Create PR

- Check existing: `gh pr view --json state 2>/dev/null`.
  - Open → reuse, skip creation.
  - Merged/closed → warn and **stop**.
- Create: `gh pr create --base <base> --title "<subject>" --body "<body>"`.
  - Title = commit subject (includes emoji if `--emoji` was active).
  - Body = commit body, or diff stat summary. Multi-commit: list subjects.
- Print PR URL.

## 10d. Merge

- `gh pr merge --rebase --delete-branch`.
  - `--rebase` preserves split commits and linear history.
  - `--delete-branch` removes remote feature branch.
- **Failure modes** (report and stop):
  - Required reviews → "PR requires review. Open at <URL>."
  - Failing/pending checks → "Checks pending. Open at <URL>."
  - Other → report `gh` output.

## 10e. Local cleanup

`gh pr merge --rebase --delete-branch` (step 10d) already checks out the
base branch, pulls, and deletes the local feature branch. Do **not** re-run
those commands manually.

1. `git log --oneline -3` — confirm the landed commits.
2. Print: `"Landed <branch> into <base>: <hash> <subject>"`.

## Step overrides

- **Step 2**: `--land`/`--land-main` on `main` = hard error. Offer to
  create a feature branch and move unpushed commits there. If accepted,
  proceed with land workflow from the new branch.
- **Step 9**: After post-commit, proceed to 10a–10e above.
