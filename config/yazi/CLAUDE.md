# Yazi Configuration

- **Docs**: https://yazi-rs.github.io/docs/configuration/overview/
- **Installed version**: Yazi 26.1.22 (verified 2026-02-26)

## Overview

Terminal file manager with vim-style keybindings. Three-panel layout
(parent/current/preview) with Catppuccin Mocha color theme.

## File Structure

| File           | Purpose                                          |
| -------------- | ------------------------------------------------ |
| `yazi.toml`    | Main config (panel ratio, sort, linemode)        |
| `keymap.toml`  | Comprehensive vim-style keybindings (~500 lines) |
| `theme.toml`   | Theme flavor selection                           |
| `package.toml` | Package manifest (flavors + plugins via `ya pkg`)|
| `flavors/`     | Deployed flavors (managed by `ya pkg`)           |

## Key Settings

- **Panel ratio**: `[1, 3, 2]` (parent, current, preview)
- **Sort**: by modification time, reversed (newest first)
- **Show hidden files**: always enabled
- **Linemode**: `size` (shows file sizes)
- **Theme**: Catppuccin Mocha for both dark/light
- **Vim keybindings**: hjkl nav, visual mode, `z` for zoxide, `Z` for fzf

## Theme Management

Flavors are managed via `ya pkg` (yazi's built-in package manager).
Do NOT manually vendor flavor files — use `ya pkg` commands instead.

- **Add a flavor**: `ya pkg add <owner>/<repo>:<flavor>`
  (e.g., `ya pkg add yazi-rs/flavors:catppuccin-mocha`)
- **List installed**: `ya pkg list`
- **Upgrade all**: `ya pkg upgrade`
- **Remove a flavor**: `ya pkg delete <flavor>`
- **Set active flavor**: edit `dark`/`light` in `theme.toml` under `[flavor]`
- **Clear cache**: `yazi --clear-cache`

`package.toml` tracks installed packages with pinned revisions — commit
this file to keep flavor versions reproducible.

## Cross-Tool References

- **fzf**: keybind `Z` for directory jump
- **zoxide**: keybind `z` for smart cd
- **ripgrep/fd**: search integration
- **zsh**: `y` wrapper function preserves cwd on exit

## Development Notes

- Reload: automatic on config change
- Schema: https://yazi-rs.github.io/schemas/yazi.json
- Help overlay: press `~` in yazi
- Nvim autocmd clears yazi cache on `yazi.toml` save
