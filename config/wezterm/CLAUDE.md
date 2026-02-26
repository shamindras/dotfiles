# WezTerm Configuration

## Overview
WezTerm terminal emulator config using Lua. Modular architecture with
registry-based theme/font selection. WezTerm serves as the GPU-accelerated
renderer and input translator — all multiplexing (panes, windows, sessions)
is handled by tmux. CMD shortcuts are intercepted by WezTerm and translated
into tmux prefix sequences.

Docs: https://wezfurlong.org/wezterm/config/files.html
Installed version: wezterm 20240203-110809-5046fc22 (verified 2026-02-22)

## Architecture

### Files
- `wezterm.lua` — Entry point. Chains module `.setup(config)` calls.
- `utils/appearance.lua` — Fonts, themes, opacity, window decorations.
  Contains `active` registry table and `font_library`/`theme_library` lookups.
- `utils/core.lua` — Shell, PATH (for direct command spawns).
- `utils/keybindings.lua` — All key/mouse bindings. Uses `tmux()` and
  `tmux_shift()` helpers to translate CMD shortcuts into tmux prefix sequences.

### Key Patterns
- **Module pattern**: Each module exports `M.setup(config)`, mutates and
  returns config. Main file chains them.
- **Registry pattern** (appearance.lua): The `active` table is the single
  source of truth. Libraries below define options. To change theme/font,
  edit ONLY the `active` table.
- **tmux passthrough**: `tmux(key, tmux_key)` sends `C-a` (tmux prefix)
  followed by `tmux_key` when `CMD+key` is pressed. `tmux_shift()` does
  the same for `CMD+SHIFT+key`. `tmux_ctrl()` does the same for
  `CMD+CTRL+key`. WezTerm never manages panes or tabs — tmux handles
  all multiplexing. Full binding reference: [`keybindings-reference.md`](keybindings-reference.md)
  — update it whenever bindings change in `utils/keybindings.lua`.
- **Dark/light detection**: `depending_on_appearance()` handles both string
  and boolean API returns from `wezterm.gui.get_appearance()`.

### Conventions

- **Lua conventions**: see `.claude/conventions/lua.md` (fold markers, stylua, module pattern)
- Formatting: stylua (2-space indent, single quotes)
- Tab bar: intentionally disabled
- Modifier convention: CMD (L0) for pane/window actions, CMD+SHIFT (L1) for
  modify/destructive/create variants, CMD+CTRL (L2) for session-scope operations

## Development Notes
- Changes apply on save (no restart needed)
- Debug with `wezterm.log_info()`, view in debug overlay (CTRL+SHIFT+L)
- Format with: `just stylua_config`
- Test in isolation: `wezterm --config-file /path/to/wezterm.lua`
