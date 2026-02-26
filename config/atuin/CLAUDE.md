# Atuin Configuration

- **Docs**: https://docs.atuin.sh/
- **Installed version**: atuin 18.12.1 (verified 2026-02-26)

## Overview

Shell history sync and search. Fuzzy search with compact inline UI.
Currently commented out in zsh config (`10-z1-brew-apps.zsh`).

## File Structure

| File          | Purpose                       |
| ------------- | ----------------------------- |
| `config.toml` | Single config file (14 lines) |

## Key Settings

- **Auto-sync**: `false` (manual `atuin sync` only)
- **Search mode**: `fuzzy`
- **Style**: `compact` with inverted colors
- **Inline height**: 16 lines
- **Preview**: enabled with 3-line scroll context
- **Update check**: disabled

## Cross-Tool References

- Integrates with **zsh** (history sync, init in `10-z1-brew-apps.zsh`)
- Database stored at `~/.local/share/atuin/` (XDG_DATA_HOME)

## Development Notes

- Reload: shell restart needed after config change
- Manual sync: `atuin sync`
