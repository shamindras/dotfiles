# Yazi Configuration

- **Docs**: https://yazi-rs.github.io/docs/configuration/overview/
- **Installed version**: Yazi 26.1.22 (verified 2026-04-20)

## Overview

Terminal file manager with vim-style keybindings. Three-panel layout
(parent/current/preview) with Catppuccin Mocha color theme. Community
plugins and flavors are managed exclusively via `ya pkg` (yazi's
built-in package manager, stable since v25.5.28). One hand-rolled
local plugin lives alongside the ya pkg-managed ones.

## File Structure

| Path                              | Purpose                                                        |
| --------------------------------- | -------------------------------------------------------------- |
| `yazi.toml`                       | Main config — only non-default `[mgr]`, openers, previewers    |
| `keymap.toml`                     | `prepend_keymap` only — yazi merges with its preset            |
| `theme.toml`                      | Flavor selection (`dark`/`light` slots)                        |
| `package.toml`                    | Pinned plugin + flavor revisions (committed for reproducibility)|
| `flavors/*.yazi/`                 | Deployed flavors (managed by `ya pkg`)                         |
| `plugins/*.yazi/`                 | Deployed plugins (managed by `ya pkg`)                         |
| `plugins/flavor-picker.yazi/`     | Hand-rolled local plugin — committed, NOT in `package.toml`    |

## Key Settings (yazi.toml)

- **Panel ratio**: `[1, 3, 2]` (parent, current, preview)
- **Sort**: by modification time, reversed (newest first)
- **Show hidden files**: always enabled
- **Linemode**: `size` (shows file sizes)
- **Previewers**: djvu-view for `.djvu`/`.djv`, ouch for archive mimes

## Theme

- **Dark flavor**: `catppuccin-mocha` (default)
- **Light flavor**: `catppuccin-latte`
- Yazi honors macOS Appearance automatically — dark/light slot is chosen
  at launch; **theme.toml is NOT live-reloaded**, any flavor change
  requires relaunching yazi.

### Flavor picker (hand-rolled plugin)

Keybind `F` launches `plugins/flavor-picker.yazi/main.lua`:

1. fzf picks a flavor from `~/.config/yazi/flavors/*.yazi`
2. fzf picks a slot: `dark`, `light`, or `both`
3. `theme.toml` is atomically rewritten
4. `ya.emit("quit", {})` exits yazi; the zsh `y` wrapper relaunches
   with cwd preserved, and the new flavor renders on restart

## Installed plugins (ya pkg)

| Plugin                         | Purpose                                       | Keybind         |
| ------------------------------ | --------------------------------------------- | --------------- |
| `Shallow-Seek/djvu-view`       | DjVu inline preview (needs `djvulibre` brew)  | auto (previewer)|
| `ndtoan96/ouch`                | Archive preview + compress/decompress         | `C` (compress)  |
| `dedukun/relative-motions`     | Vim count motions (`3j`, `5dd`, `10gg`, …)    | digits `1`–`9`  |

## Hand-rolled local plugins (committed, NOT in `package.toml`)

| Plugin                  | Purpose                                                       | Keybind   |
| ----------------------- | ------------------------------------------------------------- | --------- |
| `flavor-picker`         | fzf-based flavor picker; rewrites `theme.toml` and quits yazi | `F`       |
| `smart-archive-enter`   | dirs = enter; archives = `unar -d` extract + auto-cd; files = open | `<Enter>` |

## Installed flavors (16 total, ya pkg)

Catppuccin (mocha, latte, frappe, macchiato), Dracula, Tokyo Night,
Kanagawa (default, dragon, lotus), Gruvbox (dark, material),
Everforest Medium, Rosé Pine (default, moon, dawn), Nord.

## Keybindings (custom only — preset bindings from yazi defaults still apply)

| Key         | Action                                                           |
| ----------- | ---------------------------------------------------------------- |
| `z`         | Jump to directory via zoxide plugin                              |
| `Z`         | Jump to file/dir via fzf plugin                                  |
| `F`         | Flavor picker (fzf-based, auto-quits for relaunch)               |
| `<Enter>`   | smart-archive-enter (dir = enter, archive = extract+cd, file = open) |
| `C`         | Compress selection with ouch                                     |
| `1`–`9`     | Count prefix for relative-motions (was tab switch in defaults)   |
| `g1`–`g9`   | Switch to tab N (replaces default `1`–`9`)                       |

All other keybindings are yazi's preset defaults (see `~` help overlay).

## Package management (ya pkg)

`ya pkg` is the canonical tool for adding, updating, and removing
community plugins and flavors. Do NOT vendor files manually.

- **Add**: `ya pkg add <owner>/<repo>` (single-flavor/plugin repo) or
  `<owner>/<repo>:<subdir>` (multi-flavor repo like `yazi-rs/flavors`)
- **List**: `ya pkg list` (or `just yazi_plugins_list`)
- **Upgrade all**: `ya pkg upgrade` (or `just yazi_plugins_upgrade`)
- **Install from package.toml**: `ya pkg install`
  (or `just yazi_plugins_install` — runs idempotently during `./install`)
- **Remove**: `ya pkg delete <id>`
- **Clear cache**: `yazi --clear-cache` (or `just yazi_clear_cache`)

`package.toml` tracks every installed package with a pinned revision
and content hash — commit this file to keep state reproducible.

## Cross-Tool References

- **fzf**: keybind `Z` for directory jump; also used by flavor-picker
- **zoxide**: keybind `z` for smart cd
- **ripgrep/fd**: search integration
- **djvulibre**: brew package — `djvu-view` calls `ddjvu`
- **ouch**: brew package — CLI for compress/decompress
- **unar**: brew package — backend for `smart-archive-enter`, invoked
  with `-d` (always wrap) `-r` (rename on collision) `-o <cwd>`
- **zsh**: `y` wrapper function preserves cwd on exit (also re-entry
  point after `F` flavor-picker quits yazi)
- **tmux**: `prefix o y` launches yazi
- **wezterm**: `CMD+Y` launches yazi

## Development Notes

- **Reload caveat**: yazi merges its preset keymap with user
  `prepend_keymap`. Adding `[mgr].keymap` (as opposed to
  `prepend_keymap`) would REPLACE the preset — don't.
- **theme.toml NOT live-reloaded**: flavor switch requires yazi restart.
  This is why the flavor-picker emits `quit`.
- **Schema**: https://yazi-rs.github.io/schemas/yazi.json
- **Help overlay**: press `~` in yazi
- Nvim autocmd clears yazi cache on `yazi.toml` save.
