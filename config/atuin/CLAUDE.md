# Atuin Configuration

- **Docs**: https://docs.atuin.sh/
- **Installed version**: atuin 18.13.4 (verified 2026-03-25)

## Overview

Shell history search replacing fzf Ctrl-R. Fuzzy search with compact
inline UI and vi keymap. Init cached via `__memoize_cmd` for fast startup.

## File Structure

| File          | Purpose                       |
| ------------- | ----------------------------- |
| `config.toml` | Single config file            |

## Key Settings

| Setting                             | Value        | Why                                       |
| ----------------------------------- | ------------ | ----------------------------------------- |
| `auto_sync`                         | `false`      | Local-only history                        |
| `search_mode`                       | `fuzzy`      | Match anywhere in command                 |
| `style`                             | `compact`    | Minimal UI                                |
| `invert`                            | `true`       | Search bar at top                         |
| `keymap_mode`                       | `vim-insert` | Matches zsh vi mode                       |
| `workspaces`                        | `true`       | Filter by git repo context                |
| `filter_mode_shell_up_key_binding`  | `host`       | Up arrow filters by host                  |
| `enter_accept`                      | `true`       | Enter executes, tab edits                 |
| `history_filter`                    | regex list   | Exclude commands with KEY/SECRET/TOKEN    |

## Shell Integration

- Ctrl-R → atuin search (replaces fzf reverse search)
- Up arrow → zsh `history-search-backward` (atuin up-arrow disabled)
- Init via `__memoize_cmd` in `10-z1-brew-apps.zsh` (~1ms cached vs 670ms raw)

## Cross-Tool References

- **zsh**: init in `10-z1-brew-apps.zsh`, enabled in `.zshrc`
- **fzf**: Ctrl-R now handled by atuin; fzf retains Ctrl-T and Alt-C
- Database: `~/.local/share/atuin/` (XDG_DATA_HOME)
- Config: `~/.config/atuin/` (XDG_CONFIG_HOME, symlinked by dotbot)
- Logs: `~/.local/share/atuin/logs/` — set via `[logs] dir` in
  `config.toml` (atuin exposes no env var for this; default is
  `~/.atuin/logs`).
