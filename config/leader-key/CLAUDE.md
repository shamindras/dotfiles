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
- **Application launching**: 14 macOS apps (1password, firefox, signal,
  spotify, vlc, vscode, etc.)
- **Application quitting**: sophisticated quit with sleep delays and
  aerospace workspace navigation
- **Utility commands**: brew upgrade (`--greedy-auto-updates`),
  close-notifications, move-files, restart-leaderkey, trash-empty,
  toggle-mute, wash-dropbox
- **URLs**: Claude, Google Keep, personal repos (codebox, dotfiles), homepage,
  neovim config, blog, quarto-blog
- **Action types**: `url`, `application`, `command`, `group` (container)

## Cross-Tool References

- Integrates with **aerospace** for workspace navigation post-quit/launch
- Launches **wezterm**, **ghostty**, **lazygit**
- Uses system `fd` for file operations

## Quit Workspace Defaults

The quit group navigates to a default workspace after quitting each app:

- **Terminal-default (W)**: DJView, Preview, Finder, Skim — after
  quitting, navigate to workspace W (WezTerm)
- **VSCode-default (K)**: VSCode — after quitting, navigate to workspace K
- **Browser-default (B)**: 1Password, Firefox, Signal, Books, Spotify,
  NordVPN, VLC, JDownloader — after quitting, navigate to workspace B
- **Terminal conditionals**: quit-Ghostty checks if WezTerm is running → W,
  else B. Quit-WezTerm checks if Ghostty is running → T, else B

If WezTerm's workspace changes, update the terminal-default targets and the
quit-Ghostty conditional. See `config/wezterm/CLAUDE.md` for the source of
truth on the workspace letter.

## Development Notes

- Reload: custom `r r` (restart-leaderkey) command kills and relaunches app
- Nvim autocmd in `config/nvim/lua/shamindras/core/autocmds.lua` restarts
  the app on save of `leader-key/config.json`
- Config is JSON — validated by app on load
