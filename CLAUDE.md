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
- `submods/` - Git submodules (dotbot and plugins)
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

- Some tool directories (e.g., `config/wezterm/`) contain local `CLAUDE.md` files with tool-specific architecture documentation
- Configurations follow XDG specification strictly
- Use existing patterns when adding new tool configs
- All Lua configs should be formatted with stylua
- Homebrew packages managed through Brewfile
- Git submodules used for external dependencies
- Shell scripts follow bash strict mode (`set -Eeuo pipefail`)

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

### Tool-specific CLAUDE.md files

Each `config/<tool>/CLAUDE.md` must include:
- **Docs link**: URL to the tool's official documentation or GitHub repo
- **Installed version**: output of `<tool> --version` at time of writing
- Config file structure and key conventions

## Workflow

- **Task tracking** — Use the todo list (`TaskCreate` / `TaskUpdate` /
  `TaskList`) for all multi-step operations, including planning. Show progress
  to the user. Before marking a task complete, verify it works.
- **Cleanup before merge** — Run `just clean` and remove any temporary files
  created during Claude Code sessions (e.g., `/tmp` artifacts, stale files in
  subdirectories) before final merges. After user corrections, record the
  lesson in auto-memory for future sessions.

## Git Workflow

- **Use conventional commits**: `<type>(<scope>): <description>` format
- **Scope = tool name**: Match the tool in `config/` directory (e.g., `(nvim)`, `(zsh)`, `(brew)`)
- **Split commits by scope**: Default behavior is one commit per tool, even within shared files
- Use `/commit` skill with flags: `--staged`, `--all`, `--draft`, `--amend`, `--all-and-push`, `--no-split`
- Detailed conventions: `.claude/skills/git/workflow.md`
- Full `/commit` documentation: `.claude/skills/git/commands/commit.md`

### Examples
```
feat(ghostty): add terminal configuration
refactor(nvim): update telescope keybindings
chore(brew): update brewfile
```