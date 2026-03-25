# Ghostty Configuration

- **Docs**: https://ghostty.org/docs
- **Installed version**: Ghostty 1.1.3 (verified 2026-02-26)

## Overview

Ghostty is a GPU-accelerated terminal emulator. Minimal config — used
alongside wezterm (workspace W), assigned to workspace T in aerospace.

## File Structure

| File     | Purpose                                     |
| -------- | ------------------------------------------- |
| `config` | Single config file (shell-comment syntax)   |

## Key Settings

- **Title**: fixed "Ghostty" (security: disables arbitrary title sequences)
- **Shell integration**: `zsh` with `no-cursor,sudo,title` features
- **Font**: CommitMono Nerd Font at 20pt
- **Window**: maximized by default (`width=9999, height=9999`),
  `window-save-state=always`
- **Theme**: Catppuccin dual-mode (`light:catppuccin-mocha,dark:catppuccin-macchiato`)
- **Background opacity**: 0.9
- **Cursor**: block, non-blinking, inverted colors

## Cross-Tool References

- Assigned to workspace T in **aerospace**
- Launched/quit via **leader-key**

## Theme Management

Ghostty ships built-in themes — no external files needed.

- **Set theme**: edit `theme = <name>` in `config` (supports dual-mode:
  `light:<name>,dark:<name>`)
- **List themes**: check https://ghostty.org/docs/config/reference#theme

## Development Notes

- Reload: automatic on file change
- TERM override set in zsh env for color support
