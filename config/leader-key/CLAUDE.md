# Leader Key Configuration

- **Docs**: https://www.leader-key.com/
- **Installed version**: leader-key 1.17.3 (verified 2026-02-26)

## Overview

macOS app launcher with hierarchical keyboard-driven menus. Five top-level
action groups for opening/quitting apps, running commands, and quick URLs.

## File Structure

| File          | Purpose                                     |
| ------------- | ------------------------------------------- |
| `config.json` | Hierarchical action/command structure (323 lines) |

## Key Settings

- **Action groups**: `claude`, `open`, `quit`, `run`, `search-raycast`, `urls`
- **Application launching**: 13 macOS apps (1password, firefox, signal,
  spotify, vscode, etc.)
- **Application quitting**: sophisticated quit with sleep delays and
  aerospace workspace navigation
- **Utility commands**: brew upgrade, move-files, restart-leaderkey,
  trash-empty, toggle-mute, wash-dropbox
- **URLs**: Claude, personal repos (codebox, dotfiles), homepage, neovim config
- **Action types**: `url`, `application`, `command`, `group` (container)

## Cross-Tool References

- Integrates with **aerospace** for workspace navigation post-quit/launch
- Launches **wezterm**, **ghostty**, **lazygit**
- Uses system `fd` for file operations

## Development Notes

- Reload: custom `r` (restart-leaderkey) command kills and relaunches app
- Config is JSON — validated by app on load
