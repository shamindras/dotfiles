# tmux Configuration

## Overview
tmux multiplexer config managing sessions, windows, and panes. WezTerm
serves as the input layer — CMD shortcuts are translated into tmux prefix
sequences via WezTerm's `tmux()` / `tmux_shift()` helpers.

Docs: https://man7.org/linux/man-pages/man1/tmux.1.html

## File Structure
- `tmux.conf` — Single config file with all settings and bindings.

## Key Patterns

### Prefix
- **`C-a`** (remapped from default `C-b`)
- `C-a C-a` sends literal `C-a` to the shell

### Vim-aware pane navigation
Root-table bindings (no prefix needed). Uses `if-shell` with a `ps` regex
to detect vim/nvim/fzf in the active pane:
- `C-h` / `C-j` / `C-k` / `C-l` — select pane or forward to vim
- The regex matches: `vim`, `nvim`, `view`, `fzf`, and variants

### Custom bindings (after prefix)
| Key | Action |
|-----|--------|
| `\|` | Split pane horizontally |
| `-` | Split pane vertically |
| `x` | Kill pane (no confirmation) |
| `g` | Lazygit in new window |
| `K` | Clear pane and scrollback |
| `S` | New session |
| `r` | Reload tmux config |
| `v` | Enter copy mode |

### WezTerm CMD shortcut integration
WezTerm intercepts CMD+key and sends `C-a` + tmux_key. Examples:
- `CMD+D` → `C-a |` (split right)
- `CMD+T` → `C-a c` (new window)
- `CMD+K` → `C-a s` (session picker)
- `CMD+G` → `C-a g` (lazygit)

See `config/wezterm/utils/keybindings.lua` for the full mapping.

## Conventions
- Split bindings: `|` for horizontal, `-` for vertical
- Vi copy-mode: `v` to select, `y` to yank (system clipboard via `set-clipboard on`)
- Base index: windows start at 1 (not 0)
- Mouse: enabled
- Status bar: top position, minimal formatting

## Development Notes
- Reload config: `prefix + r` (or `tmux source-file ~/.config/tmux/tmux.conf`)
- Debug options: `tmux show-options -g` / `tmux show-options -s`
- List bindings: `tmux list-keys`
- Check key conflicts: `tmux list-keys | grep <key>`
