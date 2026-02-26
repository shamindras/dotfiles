# bottom Configuration

- **Docs**: https://clementtsang.github.io/bottom/stable/
- **Installed version**: bottom 0.12.3 (verified 2026-02-25)

## Overview

bottom (btm) is a cross-platform process/system monitor. It replaces btop in
this setup — btop mutates its config on UI interactions, bottom does not.

## File Structure

| File          | Purpose                                            |
| ------------- | -------------------------------------------------- |
| `bottom.toml` | All config: flags, process columns, styles, layout |
| `CLAUDE.md`   | This file                                          |

## Config Sections

| Section       | Purpose                                    |
| ------------- | ------------------------------------------ |
| `[flags]`     | Runtime defaults (refresh rate, temp, etc.) |
| `[processes]` | Process widget column selection             |
| `[styles.*]`  | Linkarzu color theme (inline, no ext files) |
| `[[row]]`     | Layout: processes only (full screen)        |

## Theme

Colors are inline under `[styles]` subsections. No external theme files.
Palette mapped from the linkarzu-btop theme. To swap themes, replace hex
values in `[styles]`. Catppuccin themes available at
https://github.com/catppuccin/bottom.

## Key Bindings (built-in, not configurable)

| Key        | Action                     |
| ---------- | -------------------------- |
| `q`        | Quit                       |
| `e`        | Toggle expanded widget     |
| `j/k`      | Navigate up/down in tables |
| `h/l`      | Navigate left/right        |
| `gg` / `G` | Jump to first/last entry   |
| `/`        | Search processes           |
| `m`        | Sort by memory             |
| `c`        | Sort by CPU                |
| `p`        | Sort by PID                |
| `n`        | Sort by name               |
| `t`        | Toggle tree mode           |
| `Tab`      | Toggle group-by-name       |
| `d+d`      | Kill selected process      |
| `?`        | Help menu                  |

## Development Notes

- Validate config: `btm --config ~/.config/bottom/bottom.toml`
- Config is NOT mutated by runtime UI interactions (safe for VCS)
- No shell alias — invoke directly as `btm` or via `CMD+B` tmux popup
