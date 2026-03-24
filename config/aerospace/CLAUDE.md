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
- **Startup**: `after-startup-command` is empty — `borders` and `sketchybar`
  are managed as brew services (launchd). AeroSpace only registers the
  workspace-change trigger for sketchybar via `exec-on-workspace-change`
- **App routing**: `on-window-detected` maps 40+ apps to workspaces (1-9, A-Z)
  by `app-id`; system utils float
- **Keybindings**: Alt+hjkl (focus), Alt+Shift+hjkl (move), Alt+number/letter
  (workspace), service mode (`Alt+Shift+;`) for layout toggle and reload

## Cross-Tool References

- **sketchybar**: workspace display, top gap accommodation
- **borders**: window border rendering, launched on startup
- **wezterm**: assigned to workspace W
- **ghostty**: assigned to workspace T
- **vscode**: assigned to workspace S
- **vlc**: assigned to workspace V
- **textedit**: assigned to workspace Q

## Reserved Alt Keys (Non-Workspace)

These `alt-` bindings are used for navigation/modes and **must not** be
reassigned to workspaces. Forgetting this causes silent conflicts (the
workspace binding is ignored because the existing binding takes priority).

| Binding                | Purpose                   | Mode |
| ---------------------- | ------------------------- | ---- |
| `alt-h/j/k/l`         | focus left/down/up/right  | main |
| `alt-shift-h/j/k/l`   | move left/down/up/right   | main |
| `alt-f`                | fullscreen                | main |
| `alt-shift-r`          | enter resize mode         | main |
| `alt-slash`            | layout tiles toggle       | main |
| `alt-comma`            | layout accordion toggle   | main |
| `alt-tab`              | workspace-back-and-forth  | main |
| `alt-shift-tab`        | move-workspace-to-monitor | main |
| `alt-shift-semicolon`  | enter service mode        | main |
| `alt-shift-period`     | toggle sketchybar         | main |

**When adding a new workspace letter**, verify that both `alt-<letter>` and
`alt-shift-<letter>` are free. If either is reserved above, pick a different
letter — do not silently shadow the existing binding.

## Workspace ↔ Leader-Key Alignment

Aerospace workspace letters and leader-key open/quit keys should stay in
sync. When an app's workspace letter changes here, update these in
`config/leader-key/config.json`:

1. **open group**: the key that launches the app
2. **quit group**: the key that quits the app AND the fallback workspace
   in the quit command

See `config/leader-key/CLAUDE.md` § "Workspace Alignment" for the
matching table.

## Development Notes

- Reload: `Alt+Shift+;` then `Esc` (service mode → reload-config)
- Nvim autocmd in `config/nvim/lua/shamindras/core/autocmds.lua` fires
  `aerospace reload-config` on `aerospace.toml` save
