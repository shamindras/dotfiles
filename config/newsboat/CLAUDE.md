# Newsboat Configuration

- **Docs**: https://newsboat.org/releases/2.42/docs/newsboat.html
- **Installed version**: Newsboat 2.42.0 (verified 2026-02-26)

## Overview

Terminal RSS/Atom feed reader with vim-style navigation and Dracula
color theme.

## File Structure

| File       | Purpose                                    |
| ---------- | ------------------------------------------ |
| `config`   | Main config (67 lines, shell-comment)      |
| `urls`     | Feed list (one per line with tags)         |
| `themes/`  | Color schemes (dracula active, latte/dark) |

## Key Settings

- **Auto-reload**: every 3 minutes, 4 threads
- **Download**: 4 retries, 10s timeout
- **Text width**: 80 columns
- **Browser**: `firefox --new-tab %u`
- **Navigation**: vim-style — hjkl, `d/u` pagedown/up, `G/g` end/home
- **Article actions**: `a` toggle read, `n/N` next/prev unread
- **Theme**: Dracula (via include from `themes/`)
- **Exit**: no confirmation, cleanup disabled

## Cross-Tool References

- Opens links in **firefox**
- sesh session "rss" runs newsboat in window 1

## Development Notes

- Reload feeds: `R` key in-app
- Config validated on startup
