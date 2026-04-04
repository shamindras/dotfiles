# Raycast Configuration

- **Docs**: <https://manual.raycast.com>
- **Installed version**: Raycast 1.104.11 (verified 2026-04-04)

## Overview

Raycast has no file-based config to symlink. Settings are managed via
encrypted `.rayconfig` exports, triggered by deeplinks and imported on
new machines manually. Like Dropbox, this is a manual post-install step
kept out of `./install` for idempotency.

## File structure

| Path                 | Purpose                                          |
| -------------------- | ------------------------------------------------ |
| `CLAUDE.md`          | This file — tool-specific docs                   |
| `Raycast.rayconfig`  | Encrypted settings export (AES-256-CBC, ~143 KB) |

## Deeplinks

| Action | Deeplink                                                        |
| ------ | --------------------------------------------------------------- |
| Export | `raycast://extensions/raycast/raycast/export-settings-data`     |
| Import | `raycast://extensions/raycast/raycast/import-settings-data`     |

## What the export includes

**Checked** (safe for public git):
- Settings (aliases, hotkeys, favorites)
- Extensions (references + settings, not binaries)
- Quicklinks

**Unchecked** (personal data risk or not needed):
- AI Chats, Presets & Commands
- Clipboard History
- MCP Servers
- Raycast Focus Categories
- Raycast Notes
- Script Directories
- Snippets

## What the export does NOT include

- Store extension binaries (must reinstall from Store)
- OAuth tokens / API keys (must re-authenticate per extension)
- Extension `localStorage` data
- Raycast Pro / AI account config (tied to account)

## Git safety

The `.rayconfig` file is AES-256-CBC encrypted with a passphrase.
Safe for public repos with a strong passphrase stored in a password
manager. The file is marked as `binary` in `.gitattributes` so git
does not diff or normalize line endings.

## Existing machine (periodic backup)

1. Run `just raycast_export` (or Leader Key `r e`)
2. Hit Export, enter passphrase
3. Save to `config/raycast/Raycast.rayconfig`
4. Commit the updated `.rayconfig`

## New machine (restore after `./install`)

1. Open Raycast and sign in to your account
2. Run `just raycast_import` (or Leader Key `r i`)
3. Hit Import, enter passphrase
4. Select `config/raycast/Raycast.rayconfig`
5. Reinstall Store extensions (references restored, binaries are not)
6. Re-authenticate any extension OAuth tokens / API keys
