# Git Workflow

## Branching

- Always branch from `main`.
<!-- REPO-SPECIFIC: branching-examples -->
- Format: `<type>/<short-kebab-desc>` (e.g. `feat/add-ghostty-config`, `fix/nvim-treesitter`).
<!-- END REPO-SPECIFIC -->
- Keep branch names short and descriptive.

## Proactive Branch Awareness

During `/commit`, Claude applies judgment about the current branch:
- **On a feature branch**: proceed without interruption.
- **On `main` with trivial changes**: note the branch, proceed.
- **On `main` with non-trivial changes**: proactively suggest creating a
  feature branch before committing (soft suggestion, user can override).

Goal: keep `main` clean by default without adding friction to quick fixes.

## Feature Branches in Plans

**REQUIRED**: When presenting a plan for user approval (via ExitPlanMode), the
plan file MUST include the feature branch name near the top. This is non-negotiable
— plans without an explicit branch declaration are incomplete.

Format:

Place this immediately after the Context section, before implementation steps.

<!-- REPO-SPECIFIC: plan-example -->
> **Feature branch**: `refactor/tmux-config` (from `main`)
<!-- END REPO-SPECIFIC -->

## Conventional Commits

Format: `<type>(<scope>): <description>`

### Rules

- Subject line ≤72 characters.
- Imperative mood, lowercase after colon, no trailing period.
- Body (optional) wrapped at 79 characters — explains what/why, not how.

### Types

Primary (used most often):

| Type | When to use |
|------|-------------|
<!-- REPO-SPECIFIC: types -->
| `feat` | New config, tool, script, or feature |
| `fix` | Broken config, wrong setting, runtime error fixed |
| `refactor` | Restructured existing config, no behavior change |
| `docs` | README, CLAUDE.md, skill files, comments-only changes |
| `chore` | Deps, lockfile, Brewfile, tooling, submodules |
<!-- END REPO-SPECIFIC -->

Others (use when they clearly apply):

| Type | When to use |
|------|-------------|
<!-- REPO-SPECIFIC: types-secondary -->
| `test` | Added or updated tests |
| `style` | Formatting-only (rare — most tools auto-format) |
| `ci` | CI/CD pipeline files |
<!-- END REPO-SPECIFIC -->

### Type Selection Heuristic

<!-- REPO-SPECIFIC: type-heuristic-1 -->
1. Does the diff add a **new** config/tool/capability? → `feat`
<!-- END REPO-SPECIFIC -->
2. Does it **fix** something that was broken? → `fix`
3. Does it **move/rename/restructure** without changing behavior? → `refactor`
4. Is it **only** documentation or comments? → `docs`
<!-- REPO-SPECIFIC: type-heuristic-5 -->
5. Is it tooling, deps, Brewfile, or submodules? → `chore`
<!-- END REPO-SPECIFIC -->
6. Does it add/update **tests**? → `test`
7. None of the above? Re-read the diff — one of the above almost always fits.

### Scopes

<!-- REPO-SPECIFIC: scopes -->
**By tool** (corresponds to `config/<tool>/` directories):
- `(nvim)` — Neovim configuration
- `(zsh)` — ZSH shell configuration
- `(brew)` — Homebrew/Brewfile changes
- `(tmux)` — Tmux configuration
- `(git)` — Git configuration
- `(aerospace)` — Window manager config
- `(karabiner)` — Keyboard remapping
- `(wezterm)`, `(ghostty)` — Terminal configs
- `(leader-key)` — Leader key shortcuts
- `(yazi)`, `(lazygit)` — File/git TUIs
- `(surfingkeys)`, `(vimium)` — Browser vim extensions
- `(marimo)` — Marimo notebook config
- `(newsboat)` — RSS reader
- `(bat)`, `(ripgrep)`, `(starship)` — CLI tools
- And any other tool in `config/` directory

**Special scopes:**
- `(macos)` — macOS system defaults/settings
- `(dotbot)` — Installation configuration
- `(submods)` — Git submodules
- `(scripts)` — Setup/utility scripts
- `(claude)` — Claude Code settings
- `(docs)` — Documentation (CLAUDE.md, README.md)
<!-- END REPO-SPECIFIC -->

<!-- REPO-SPECIFIC: splitting -->
## Commit Splitting (Dotfiles Convention)

### Scope-based splitting (default)

- **Default behavior: one commit per scope/tool**
- Even within single files (Brewfile, install.conf.yaml, CLAUDE.md), split hunks by the tool they relate to
- Group related changes across multiple files by scope
- This ensures a clean, semantic git history where each commit represents changes to a single tool

### When to keep changes together

- Atomic features that span multiple scopes (rare — ask user first)
- User explicitly requests combining (override default)
- Changes to shared infrastructure that genuinely affects all tools

### Example

❌ **Don't do this:**
```
chore: update configs
- Updates nvim, tmux, and brew configs
```

✅ **Do this instead:**
```
refactor(nvim): update telescope keybindings
refactor(tmux): add new pane navigation shortcuts
chore(brew): update package list
```

### Splitting shared files

When a single file (e.g., `install.conf.yaml` or `Brewfile`) contains changes for multiple tools:

1. Analyze hunks and attribute each to a scope
2. Group hunks by scope
3. Stage and commit each scope separately
4. Present the grouping plan to the user before committing

**Example:** `Brewfile` adds both `ripgrep` and `fd`
```
Proposed commits:

1. feat(ripgrep): add ripgrep for faster searching
   - config/brew/Brewfile (ripgrep entry)

2. feat(fd): add fd file finder
   - config/brew/Brewfile (fd entry)
```
<!-- END REPO-SPECIFIC -->

## Attribution

- Do **not** add a `Co-Authored-By` trailer for Claude in commit messages unless the user explicitly opts in.
- By default, commits should be authored solely by the user.

## Command conventions

- Always run `git` commands **from the repo root** using relative paths.
- **Never** use `git -C <absolute-path>` — it generates non-portable permission
  entries in `.claude/settings.local.json` and causes repeated approval prompts.
<!-- REPO-SPECIFIC: cmd-examples -->
- Reference files with repo-relative paths (e.g. `git diff -- config/nvim/init.lua`,
  not `git diff -- /Users/.../dotfiles/config/nvim/init.lua`).
<!-- END REPO-SPECIFIC -->

<!-- REPO-SPECIFIC: examples -->
## Examples

Single-line:

```
feat(ghostty): add terminal configuration
```

```
fix(nvim): correct treesitter module loading
```

```
chore(brew): update brewfile
```

Multi-line:

```
refactor(leader-key): improve shortcuts and modernize file ops

Reorganize shortcuts into logical groups and update file operations
to use modern commands. No behavior change to existing shortcuts.
```
<!-- END REPO-SPECIFIC -->
