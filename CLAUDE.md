# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal macOS dotfiles repository that follows the XDG Base Directory specification and modern Unix workflow principles. It uses dotbot for automated installation and symlink management.

## Key Commands

### Initial Setup
For first-time setup on a new macOS system:
```bash
make setup-dropbox    # Setup Dropbox (required for full config)
./install             # Install dotfiles after Dropbox sync completes
```

### Installation and Updates
```bash
./install             # Install/update dotfiles using dotbot
make dotbot_install   # Alternative wrapper for ./install
```

### Development and Maintenance
```bash
just clean            # Clean temporary files, .DS_Store, vim swap files
just stylua_config    # Format all Lua config files using stylua
just update_brewfile  # Update Homebrew bundle file from current packages
just update_submods   # Update all git submodules
just all              # Run clean, stylua_config, and update_brewfile
```

## Architecture

### Core Components

**Installation System**: Uses dotbot with `install.conf.yaml` configuration file. The `./install` script:
- Sets up XDG environment variables
- Updates dotbot submodule
- Runs dotbot with brew plugin support

**XDG Directory Structure**: All configs follow XDG specification:
- `XDG_CONFIG_HOME` (~/.config) - application configs
- `XDG_CACHE_HOME` (~/.cache) - cached data
- `XDG_DATA_HOME` (~/.local/share) - application data
- `XDG_STATE_HOME` (~/.local/state) - state files
- `XDG_RUNTIME_DIR` (~/.xdg) - runtime files
- `XDG_PROJECTS_DIR` (~/Projects) - project workspace
- `XDG_BIN_HOME` (~/.local/bin) - user binaries

### Directory Structure

- `config/` - All application configurations organized by tool
- `scripts/` - Setup and utility scripts for various components
- `submods/` - Git submodules (`core/` for dotbot, `plugins/` for runtime plugins)
- `install.conf.yaml` - Main dotbot configuration
- `justfile` - Just command runner tasks
- `Makefile` - Basic make targets for setup

### Key Scripts

- `scripts/setup-dropbox` - Dropbox installation and setup
- `scripts/setup-macos` - macOS system defaults configuration
- `scripts/setup-upgrade-homebrew` - Homebrew installation/upgrade
- `scripts/setup-upgrade-rust-cargo` - Rust toolchain management
- `scripts/setup-zk` - Zettelkasten (zk) setup

### Supported Applications

Major categories of tools configured:
- **Shells**: zsh with extensive customization
- **Editors**: neovim, vscode configurations
- **Terminals**: alacritty, ghostty, wezterm
- **Development**: git, gh, lazygit, tmux
- **System**: aerospace (window manager), karabiner (keyboard)
- **CLI Tools**: bat, ripgrep, yazi, starship, atuin
- **Languages**: rust/cargo, npm packages

### Installation Flow

The install process (`install.conf.yaml`) follows this sequence:
1. Create XDG directories
2. Clean existing symlinks
3. Setup zk (zettelkasten)
4. Create symlinks for all configs
5. Install/upgrade Homebrew
6. Install packages from Brewfile
7. Install/upgrade Rust/Cargo
8. Setup various tools (bat cache, tldr, gh extensions, espanso, ttyper)
9. Install npm packages (eslint_d, prettier)
10. Apply macOS system settings

## Development Guidelines

- Every `config/<tool>/` directory has a `CLAUDE.md` with tool-specific docs
- Configurations follow XDG specification strictly
- Use existing patterns when adding new tool configs
- All Lua configs should be formatted with stylua
- Homebrew packages managed through Brewfile
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
| leader-key  | `leader-key/config.json`                     | `killall 'Leader Key' 2>/dev/null; sleep 0.5; open -a 'Leader Key'` |
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

- **Task tracking** — Use the todo list (`TaskCreate` / `TaskUpdate` /
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