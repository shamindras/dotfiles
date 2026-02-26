# Git Configuration

- **Docs**: https://git-scm.com/docs
- **Installed version**: git 2.53.0 (verified 2026-02-26)

## Overview

Git config with delta pager, Catppuccin Mocha diff theme, and custom
aliases. Includes global ignore and attributes files.

## File Structure

| File         | Purpose                                       |
| ------------ | --------------------------------------------- |
| `config`     | Main gitconfig (editor, pager, aliases, delta) |
| `ignore`     | Global gitignore patterns                     |
| `attributes` | Line-ending normalization rules               |

## Key Settings

- **Editor**: nvim
- **Pager**: delta with Catppuccin Mocha theme
- **Delta**: side-by-side diffs, line numbers, themes from
  `config/delta/themes.gitconfig` (included via `[include]`)
- **Aliases**: `lg` (fancy log graph), `clean-branches`, `gone` (prune
  remote-deleted branches)
- **Auto-correct**: disabled
- **User**: shamindras (GitHub)

## Cross-Tool References

- Uses **delta** for diff display (theme sourced from `config/delta/`)
- Uses **nvim** as editor
- **lazygit** overrides pager settings

## Development Notes

- Test config: `git config --list --show-origin`
- Delta themes: add/change in `config/delta/themes.gitconfig`
