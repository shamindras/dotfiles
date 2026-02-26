# Alacritty Configuration

- **Docs**: https://alacritty.org/config-alacritty.html
- **Installed version**: alacritty 0.16.1 (verified 2026-02-26)

## Overview

GPU-accelerated terminal emulator. Minimal config with Tokyo Night theme
and custom Cmd+key bindings for TUI tools.

## File Structure

| File              | Purpose                                |
| ----------------- | -------------------------------------- |
| `alacritty.toml`  | Main config (TOML)                     |
| `themes/`         | Theme files (tokyonight_night.toml)    |

## Key Settings

- **Live config reload**: enabled
- **Shell**: `/bin/zsh`
- **Font**: JetBrainsMono Nerd Font at 18pt (bold/italic variants)
- **Theme**: Tokyo Night via import directive
- **Window**: `buttonless` decorations, 3px padding
- **Selection**: `save_to_clipboard = true`
- **Keybindings**: Cmd+G (lazygit), Cmd+Shift+G (gh-dash), Cmd+Y (yazi)

## Cross-Tool References

- Shells to **zsh**
- Launches **lazygit**, **gh-dash**, **yazi** via Cmd shortcuts

## Development Notes

- Reload: automatic on save
- Deprecated in Homebrew (macOS Gatekeeper); removal date 2026-09-01
