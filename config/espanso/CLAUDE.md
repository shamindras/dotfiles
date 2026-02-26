# Espanso Configuration

- **Docs**: https://espanso.org/docs/
- **Installed version**: espanso 2.3.0 (verified 2026-02-26)

## Overview

Cross-platform text expander. Clipboard-based backend on macOS with
search-only mode (no global hotkey toggle). Match files organized by
category.

## File Structure

| File                     | Purpose                              |
| ------------------------ | ------------------------------------ |
| `config/default.yml`     | Global config (backend, search, UI)  |
| `match/base.yml`         | Global variables (name, email)       |
| `match/personal.yml`     | Personal snippets (title, company)   |
| `match/datetimes.yml`    | Date/time expansions                 |
| `match/emails.yml`       | Email snippets                       |
| `match/links.yml`        | Link templates                       |
| `match/writing.yml`      | Writing helpers                      |
| `match/md-formatting.yml`| Markdown formatting shortcuts        |

## Key Settings

- **Backend**: `clipboard` (required for macOS text injection)
- **Toggle key**: `OFF` (search-only mode)
- **Search trigger**: `ALT+SHIFT+SPACE`
- **Search shortcut prefix**: `;search`
- **Auto-restart**: `true`
- **No UI**: `show_icon: false`, `show_notifications: false`
- **Undo support**: `undo_backspace: true`
- **Preserve clipboard**: `true`

## Cross-Tool References

- Floats in **aerospace** (forced floating layout)
- Global variables in `base.yml` reused via `{{VarName}}` in match files

## Development Notes

- Restart: `auto_restart: true` handles crashes; manual: `killall espanso && espanso start`
- Match files use YAML parent-child relationships
