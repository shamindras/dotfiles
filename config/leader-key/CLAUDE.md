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

- **Action groups**: `claude`, `github`, `open`, `quit`, `run`, `search-raycast`, `urls`
- **Application launching**: 14 macOS apps (1password, firefox, signal,
  spotify, vlc, vscode, etc.)
- **Application quitting**: uses `config/bin/quit-app` helper which
  polls until the app actually exits, then switches aerospace workspace
  (Finder is the sole inline exception due to its special quit sequence)
- **Utility commands**: brew upgrade (`--greedy`),
  close-notifications, move-files, raycast-export, raycast-import,
  restart-leaderkey, trash-empty, toggle-mute, wash-dropbox
- **GitHub URLs** (`g`): personal repos (codebox, dotfiles, quarto-blog),
  GitHub profile, neovim config
- **URLs** (`u`): blog, homepage, Google Keep, YouTube incognito
- **Action types**: `url`, `application`, `command`, `group` (container)

## Cross-Tool References

- Integrates with **aerospace** for workspace navigation post-quit/launch
- Launches **wezterm**, **ghostty**, **lazygit**
- Uses system `fd` for file operations

## Quit Workspace Defaults

The quit group navigates to a default workspace after quitting each app:

- **Terminal-default (W)**: DJView, Preview, Finder, Skim, TextEdit — after
  quitting, navigate to workspace W (WezTerm)
- **VSCode-default (S)**: VSCode — after quitting, navigate to workspace S
- **Browser-default (B)**: 1Password, Firefox, Signal, Books, Spotify,
  NordVPN, VLC, JDownloader — after quitting, navigate to workspace B
- **Terminal conditionals**: quit-Ghostty checks if WezTerm is running → W,
  else B. Quit-WezTerm checks if Ghostty is running → T, else B

If WezTerm's workspace changes, update the terminal-default targets and the
quit-Ghostty conditional. See `config/wezterm/CLAUDE.md` for the source of
truth on the workspace letter.

## Workspace Alignment

Leader-key open/quit keys must match the app's aerospace workspace letter.
This table is the source of truth for the mapping:

| App         | Leader key (`o`/`q`) | Aerospace workspace | Mnemonic            |
| ----------- | -------------------- | ------------------- | ------------------- |
| 1password   | `1`                  | `1`                 | **1**password       |
| djview      | `a`                  | `A`                 | **A**rchive         |
| firefox     | `b`                  | `B`                 | **B**rowser         |
| preview     | `d`                  | `D`                 | p**D**f             |
| finder      | `e`                  | `E`                 | **E**xplorer        |
| signal      | `g`                  | `G`                 | si**G**nal          |
| books       | `i`                  | `I`                 | **i**Books          |
| spotify     | `m`                  | `M`                 | **M**usic           |
| nordvpn     | `n`                  | `N`                 | **N**ordVPN         |
| skim        | `p`                  | `P`                 | **P**df             |
| textedit    | `q`                  | `Q`                 | **Q**uill           |
| vscode      | `s`                  | `S`                 | V**S**Code / editor |
| ghostty     | `t`                  | `T`                 | **T**erminal        |
| vlc         | `v`                  | `V`                 | **V**LC             |
| wezterm     | `w`                  | `W`                 | **W**ezterm         |
| jdownloader | `x`                  | `X`                 | e**X**tract         |

**When changing a workspace letter** in `config/aerospace/aerospace.toml`,
update both the open and quit entries here, including the fallback workspace
in the quit command string. See `config/aerospace/CLAUDE.md` § "Reserved
Alt Keys" before choosing a new letter — some `alt-` keys are reserved for
navigation/modes and cannot be used as workspace shortcuts.

## Development Notes

- Reload: custom `r r` (restart-leaderkey) command kills and relaunches app
- Nvim autocmd in `config/nvim/lua/shamindras/core/autocmds.lua` restarts
  the app on save of `leader-key/config.json`
- Config is JSON — validated by app on load
