# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal macOS dotfiles repository that follows the XDG Base Directory specification and modern Unix workflow principles. It uses dotbot for automated installation and symlink management.

## Key Commands

### Two commands

| Command                       | Use it when                                                           |
| ----------------------------- | --------------------------------------------------------------------- |
| `./bootstrap --profile <p>`   | Fresh Mac (any clone path, HTTPS). Installs Homebrew, then `./install`. |
| `./install`                   | Re-run on a set-up Mac; reads the profile from `~/.config/dotfiles`.  |

Profiles are `home` and `work` (`generated/<profile>/`). Both commands accept
`--links-only` (links only, no Homebrew or setup), `--dry-run` (change
nothing, print the plan) and `--no-hints`. `make bootstrap` and
`make dotbot_install` are aliases.

```bash
git clone https://github.com/shamindras/dotfiles.git ~/repos/dotfiles
~/repos/dotfiles/bootstrap --profile home
```

Re-runs are safe and idempotent. Packages install one module at a time (core
first); a failing module falls back to one package at a time, and every
failure is listed at the end instead of stopping the run. Neither command
needs Dropbox or an SSH key.

### Development and Maintenance
```bash
just                  # Interactive recipe picker (fzf + preview)
just help             # List all targets grouped by area
just all              # Write pipeline: clean → format → manifest render → firefox → treesitter → yazi
just format           # Format Lua (stylua) + markdown (prettier)
just sync-all         # Sync firefox + treesitter + yazi plugins + notes configs + submodules
just audit            # Read-only audit: firefox drift + treesitter parsers + yazi plugins
just clean            # Sweep .DS_Store, swap files, stale zsh sessions
just submods_update   # Pull latest submodule revisions
just update-all       # nvim plugins, zsh plugin pins, yazi, treesitter, submodules
just outdated         # Read-only: Homebrew outdated, zsh plugin pins, submodules
just test             # test_static + test_sandbox
just test_static      # shellcheck tests, harness self-test, docs lint, invariants
just test_sandbox     # Config load + install into a throwaway HOME (never the real one)
just manifest_check   # Validate manifest.json and check generated/ is current
just manifest_render  # Regenerate generated/<profile>/ from manifest.json
just manifest_set work zoom external   # Override one unit in one profile
just manifest_why work bat             # Why a unit is on or off
just manifest_diff    # Home-versus-work comparison
just doctor           # Read-only health report; run it first on a new Mac
just dropbox_finish   # Home: ~/Dropbox link + notes once Dropbox has synced
```

Test results are PASS, FAIL, XFAIL (fails until a named plan node lands),
XPASS (passes early) or SKIP (with a reason). Only FAIL makes a run fail.
See `scripts/CLAUDE.md` and `docs/plan/program.md`.

Recipes are grouped via `[group('<name>')]` attributes — see `just --list`.
Composites emit two-tier progress: outer `▶ X/Y` across sub-targets and
inner `├─ n/total` within each extracted script.

## Architecture

### Core Components

**Installation System**: `manifest.json` declares every tool; `scripts/ops/manifest`
renders `generated/<profile>/` (Brewfile, `dotbot.json`, `resolved.json`, `env.sh`/`env.zsh`).
`./install` reads only those committed files: it initialises the dotbot
submodule over HTTPS, links configs with dotbot, installs packages per module
with `brew bundle`, then runs the units' setup steps in dependency order.

**XDG Directory Structure**: All configs follow XDG specification:
- `XDG_CONFIG_HOME` (~/.config) - application configs
- `XDG_CACHE_HOME` (~/.cache) - cached data
- `XDG_DATA_HOME` (~/.local/share) - application data
- `XDG_STATE_HOME` (~/.local/state) - state files
- `XDG_RUNTIME_DIR` (~/.xdg) - runtime files
- `XDG_PROJECTS_DIR` (~/Projects) - project workspace
- `XDG_BIN_HOME` (~/.local/bin) - user binaries

### Directory Structure

- `manifest.json` - The one hand-maintained declaration of every tool (units, modules, profiles)
- `generated/` - Resolver output per profile (Brewfile, dotbot.json, resolved.json, env.sh/env.zsh) and `compare.md`; never hand-edit
- `config/` - All application configurations organized by tool
- `scripts/` - Setup and utility scripts for various components
- `docs/decisions/` - Decision notes (adr, invariant, pattern, vocab), one fact per file, append-only
- `docs/plan/` - Overhaul work graph (`graph.yaml`), control file (`program.md`), trial log (`trials.jsonl`)
- `.github/workflows/ci.yml` - CI: static checks on Linux, static + sandbox tests on macOS per profile
- `submods/` - Git submodules (`core/` for dotbot, `plugins/` for runtime plugins)
- `justfile` - Just command runner tasks
- `Makefile` - Basic make targets for setup

### Key Scripts

Organized by runtime role:

- `bootstrap` - fresh-Mac entry point: installs Homebrew if missing, loads
  `brew shellenv`, then hands off to `./install` with the same flags.
- `install` - links, packages per module, setup steps for one profile
  (`--profile`, `--links-only`, `--dry-run`, `--no-hints`).
- `scripts/setup/` — one-time bootstrap scripts run by `./install`:
  - `setup-macos` - macOS system defaults configuration
  - `setup-upgrade-homebrew` - Homebrew installation/upgrade
  - `setup-upgrade-rust-cargo` - Rust toolchain management
  - `setup-hammerspoon` - Configure Hammerspoon MJConfigFile + hidutil LaunchAgent
  - `setup-upgrade-ttyper` - Install/upgrade ttyper
  - `setup-zk` - Zettelkasten (zk) setup
  - `post-install-hints` - Print manual post-install steps
- `scripts/ops/` — ongoing-use scripts invoked by justfile (also some by `./install`):
  - `audit-firefox` - Audit Firefox prefs for drift
  - `setup-firefox` - Sync Firefox user.js, chrome/, policies.json
  - `setup-nvim-treesitter` - Install/update nvim-treesitter parsers
  - `sync-notes-config` - Copy prettier/markdownlint configs into `$NOTES_DIR`
- `scripts/_lib/` — sourced helpers (e.g., `step.sh` for two-tier progress)
- `scripts/test/` — test harness run by `just test*` and CI (see `scripts/CLAUDE.md`)
- `scripts/ops/manifest` — resolver: `manifest.json` → `generated/<profile>/` (Brewfile, dotbot.json, resolved.json, env.sh/env.zsh)
- `scripts/migrate/` — one-off migration utilities (unchanged)

### Supported Applications

Major categories of tools configured:
- **Shells**: zsh with extensive customization
- **Editors**: neovim, vscode configurations
- **Terminals**: ghostty, wezterm
- **Development**: git, gh, lazygit, tmux
- **System**: aerospace (window manager), hammerspoon (userspace keyboard remapper + leader sequences)
- **CLI Tools**: bat, ripgrep, yazi, starship, atuin
- **Languages**: R, rust/cargo, npm packages

### Installation Flow

`./bootstrap` installs Homebrew if missing and loads `brew shellenv` into the
same run, then hands off to `./install`, which:

1. Creates XDG directories, cleans dead links and links every config
   (dotbot, `generated/<profile>/dotbot.json`), including
   `~/.config/dotfiles/{env.sh,env.zsh,resolved.json}` for this profile
2. Installs packages module by module from `generated/<profile>/Brewfile`
3. Imports the environment `.zshenv` builds and runs the setup steps and
   services (bat cache, gh extensions, espanso, Hammerspoon, treesitter,
   yazi, TPM, macOS defaults, ...), skipping any whose command is missing

Dropbox is data only (notes, books, media) and home only. Its unit installs
the cask and, as the very last step, opens the app and prints the sign-in
hint; nothing waits for sign-in or sync. Once signed in, `just
dropbox_finish` (safe any time) creates the `~/Dropbox` link with
`scripts/ops/ensure-dropbox-link` and sets up the notes when they arrive,
then prints the one-time Finder step to pin the notes offline.

## Development Guidelines

- Every `config/<tool>/` directory has a `CLAUDE.md` with tool-specific docs
- Configurations follow XDG specification strictly
- Use existing patterns when adding new tool configs
- All Lua configs should be formatted with stylua
- Homebrew packages are declared in `manifest.json` (rendered to `generated/<profile>/Brewfile`)
- Git submodules used for external dependencies
- Shell scripts follow bash strict mode (`set -Eeuo pipefail`)

### Shared conventions for tool configs

**Lua configs** (wezterm, nvim, sketchybar): formatted with stylua (2-space
indent, single quotes). Use Neovim fold markers. Full conventions in
`.claude/conventions/lua.md`.

**Shell scripts**: standalone scripts use `set -Eeuo pipefail`. Scripts
sourced by parent processes (e.g., sketchybar items) do NOT add strict mode.

**Theme**: most tools use Catppuccin Mocha. ARGB hex format (`0xAARRGGBB`).
Canonical palette: `config/sketchybar/colors.sh`.

**Cross-tool keybinding updates**: when changing bindings in wezterm or tmux,
update both `config/wezterm/keybindings-reference.md` and the relevant
CLAUDE.md binding tables.

**Tool reload after config changes**: some tools require a reload when
their config is modified outside nvim (nvim has BufWritePost autocmds for
these, but Claude Code edits bypass them). After modifying these configs,
run the corresponding command:

| Tool        | Config file pattern                          | Reload command                                                      |
| ----------- | -------------------------------------------- | ------------------------------------------------------------------- |
| aerospace   | `aerospace.toml`                             | `aerospace reload-config`                                           |
| borders     | `bordersrc`                                  | `brew services restart borders`                                     |
| hammerspoon | `config/hammerspoon/*.lua`                   | `hs -c "hs.reload()"`                                               |
| sketchybar  | `sketchybarrc`, `colors.sh`, `items/*.sh`    | `sketchybar --reload`                                               |
| yazi        | `yazi.toml`                                  | `yazi --clear-cache`                                                |

### Design principles

- **Idempotent on existing machine**: scripts/configs safe to re-run
- **Reproducible on new machine**: fresh install reaches same state

### Version verification for tool configs

Before writing or modifying any tool configuration, **verify config field names
and syntax against the currently installed version's documentation**. Do not
rely on cached knowledge or plan-provided field names — tools rename fields
across versions (e.g., sesh v2 changed `startup_script` → `startup_command`).

1. **Check installed version**: `<tool> --version` or `brew info <tool>`
2. **Verify against current docs**: fetch the tool's README, schema, or
   `--help` output for the installed version
3. **Validate after writing**: where possible, use the tool's own validation
   (e.g., `sesh list -c --json`, `tmux show-options`, `nvim --headless`)

### Markdown files
- Keep tables column-aligned with consistent padding so they are readable
  in plain text (not just rendered HTML). Use dashed separator rows that
  match column widths.
- Linting via `markdownlint-cli2` (run by nvim-lint) uses
  `.markdownlint-cli2.yaml` at the repo root, with `MD013 line_length: 120`
  to match `.prettierrc.yaml`'s `printWidth: 120`. README/CLAUDE.md files
  must start with an H1 (MD041 stays enabled here).

### Tool-specific CLAUDE.md files

Each `config/<tool>/CLAUDE.md` must include:
- **Docs link**: URL to the tool's official documentation or GitHub repo
- **Installed version**: output of `<tool> --version` at time of writing
- Config file structure and key conventions

Files should contain ONLY tool-specific information. Shared conventions
are in root CLAUDE.md and `.claude/conventions/` — do not duplicate them.

**Keep CLAUDE.md in sync**: when modifying a tool's config, update its
`config/<tool>/CLAUDE.md` to reflect the change (new settings, changed
keybindings, updated aliases, etc.). Add this as a task when planning
multi-step work.

## Workflow

### Plan mode

- **Interview-style**: Do not present a large plan upfront. Break the work
  into modular sections and walk through each one interactively — present
  findings/proposal for one section, get input, then move to the next.
  Compile the final plan only after all sections are discussed.
- **Section-by-section implementation**: After plan approval, implement one
  section at a time, presenting diffs for approval at each step. Full
  end-to-end execution (no per-section approval) is available but opt-in —
  only proceed that way if explicitly requested.

### Task tracking

- Use the todo list (`TaskCreate` / `TaskUpdate` /
  `TaskList`) for all multi-step operations, including planning. Show progress
  to the user. Before marking a task complete, verify it works.
- **Cleanup before merge** — Run `just clean` and remove any temporary files
  created during Claude Code sessions (e.g., `/tmp` artifacts, stale files in
  subdirectories) before final merges. After user corrections, record the
  lesson in auto-memory for future sessions.

## Branch-First Rule

**Before any non-trivial work — plans, implementations, or commits — check and
declare the branch.**

- **Plan mode**: The plan file MUST include a `**Feature branch**: \`<type>/<desc>\`
  (from \`main\`)` line near the top, before implementation steps. If the plan omits
  this, add it before calling ExitPlanMode.
- **Implementation mode**: Before editing any file, run `git branch --show-current`.
  If on `main` and the work is non-trivial (3+ files, new file, multi-scope, or
  `feat`/`refactor` type), create or propose a feature branch **before** touching
  code. Do not defer to commit time.
- **Trivial exception**: Single-file typo fixes, one-line tweaks, or docs-only
  changes may proceed on `main` without a branch.
- **Branch format**: `<type>/<short-kebab-desc>` (e.g. `feat/add-ghostty-config`,
  `fix/nvim-treesitter`).

This rule takes priority over any skill-level branch check. The `/commit` skill
has its own branch check at step 2, but that is a safety net, not the primary gate.

## Git Workflow

Conventional commits via `/commit`. See `.claude/skills/git/workflow.md`
for types, scopes, and flags. Skill sync via `/sync-skill <name> --from <repo>`.