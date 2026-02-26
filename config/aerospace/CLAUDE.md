# AeroSpace Configuration

- **Docs**: https://nikitabobko.github.io/AeroSpace/
- **Installed version**: aerospace 0.20.2-Beta (verified 2026-02-26)

## Overview

AeroSpace is a tiling window manager for macOS. This config uses accordion
layout with Alt-based keybindings and maps 40+ apps to named workspaces.

## File Structure

| File             | Purpose                              |
| ---------------- | ------------------------------------ |
| `aerospace.toml` | Single monolithic config file        |

## Key Settings

- **Default layout**: `accordion` (not `tiles`), 0 padding
- **Gaps**: per-monitor outer top gap — 0 for built-in, 30px for external
  (leaves room for sketchybar)
- **Mouse**: follows focus on monitor change, `move-mouse window-lazy-center`
- **Startup**: launches `borders` and `sketchybar`, registers workspace-change
  trigger for sketchybar
- **App routing**: `on-window-detected` maps 40+ apps to workspaces (1-9, A-Z)
  by `app-id`; system utils float
- **Keybindings**: Alt+hjkl (focus), Alt+Shift+hjkl (move), Alt+number/letter
  (workspace), service mode (`Alt+Shift+;`) for layout toggle and reload

## Cross-Tool References

- **sketchybar**: workspace display, top gap accommodation
- **borders**: window border rendering, launched on startup
- **wezterm/ghostty**: assigned to workspace T
- **vscode**: assigned to workspace V

## Development Notes

- Reload: `Alt+Shift+;` then `Esc` (service mode → reload-config)
- Nvim autocmd in `config/nvim/lua/shamindras/core/autocmds.lua` fires
  `aerospace reload-config` on `aerospace.toml` save
