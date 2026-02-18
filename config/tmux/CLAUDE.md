# tmux Configuration

## Overview
tmux multiplexer config managing sessions, windows, and panes. WezTerm
serves as the input layer — CMD shortcuts are translated into tmux prefix
sequences via WezTerm's `tmux()` / `tmux_shift()` helpers.

Docs: https://man7.org/linux/man-pages/man1/tmux.1.html

## File Structure

| File | Purpose |
|------|---------|
| `tmux.conf` | Entry point — sources all modules in order |
| `options.conf` | Terminal, prefix, and core settings |
| `keybindings.conf` | Custom keybindings (splits, navigation, copy, utils) |
| `theme.conf` | Catppuccin v2 options + status bar + pane borders |
| `plugins.conf` | TPM plugin declarations + plugin options + `run tpm` |
| `.gitignore` | Ignores `plugins/` (hides TPM symlink from git) |

Source order in `tmux.conf`: options → keybindings → theme → plugins.
Theme sets `@catppuccin_*` variables before TPM runs; status format strings
use `#{E:...}` lazy expansion so they resolve at render time.

## Plugin System

### TPM setup

| Component | Location | Tracked in git? |
|-----------|----------|-----------------|
| TPM itself | `submods/tmux-plugins/tpm` | Yes (submodule ref) |
| TPM symlink | `~/.config/tmux/plugins/tpm` | No (dotbot symlink) |
| Other plugins | `~/.local/share/tmux/plugins/<plugin>/` | No (TPM managed) |
| Resurrect data | `~/.local/share/tmux/resurrect/` | No (session data) |

`TMUX_PLUGIN_MANAGER_PATH` is set in `config/zsh/conf.d/00-z1-env-vars-xdg.zsh`
to `$XDG_DATA_HOME/tmux/plugins` — TPM installs all non-TPM plugins there.

### Plugin list

| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tmux-sensible` | Universal baseline defaults |
| `tmux-plugins/tmux-yank` | System clipboard integration |
| `tmux-plugins/tmux-resurrect` | Session/window/pane persistence |
| `tmux-plugins/tmux-continuum` | Auto-save (15 min) + auto-restore |
| `catppuccin/tmux#v2.1.3` | Catppuccin mocha theme (version-pinned) |
| `wfxr/tmux-fzf-url` | Open URLs from scrollback via fzf |
| `joshmedeski/tmux-nerd-font-window-name` | Auto nerd font icons per process |

TPM itself is managed as a git submodule — do NOT declare it as `@plugin`.

### Day-to-day plugin management
- `prefix + I` — install new plugins
- `prefix + U` — update all plugins
- `prefix + alt + u` — uninstall removed plugins
- Full reinstall: `~/.config/tmux/plugins/tpm/bin/install_plugins`

## Key Patterns

### Prefix
- **`C-a`** (remapped from default `C-b`)
- `C-a C-a` sends literal `C-a` to the shell

### Vim-aware pane navigation
Root-table bindings (no prefix needed). Uses `if-shell` with a `ps` regex
to detect vim/nvim/fzf in the active pane:
- `C-h` / `C-j` / `C-k` / `C-l` — select pane or forward to vim
- Regex handles `.nvim`, NixOS `-wrapped` binaries
- Neovim side handled by `smart-splits.nvim` (`config/nvim/lua/shamindras/plugins/smart-splits.lua`)

### Custom bindings (after prefix)

| Key | Action |
|-----|--------|
| `\|` | Split pane horizontally (preserves cwd) |
| `-` | Split pane vertically (preserves cwd) |
| `c` | New window (preserves cwd) |
| `x` | Kill pane (no confirmation) |
| `g` | Lazygit in new window |
| `K` | Clear pane and scrollback |
| `S` | New session |
| `r` | Reload tmux config (with message) |
| `v` | Enter copy mode |

### Copy mode
- `prefix + v` enters copy mode
- `v` begins selection
- `y` copies to system clipboard (via tmux-yank)
- Mouse drag auto-copies (via tmux-yank)

### WezTerm CMD shortcut integration
WezTerm intercepts CMD+key and sends `C-a` + tmux_key.
See `config/wezterm/CLAUDE.md` and `config/wezterm/utils/keybindings.lua`
for the full CMD mapping.

## Theme (Catppuccin v2 Mocha)

- Flavor: `mocha`
- Window style: rounded pills
- Window text: `#{window_icon} #W` (nerd font icon + name)
- Active window: highlighted + zoom indicator (󰊓) when zoomed
- Status left: session name in rounded pill
- Status right: current directory basename
- Pane borders: magenta (active), brightblack (inactive)

Optional per-process icon overrides: `config/tmux/tmux-nerd-font-window-name.yml`
(not created yet — 174 built-in icons work out of the box).

## Development Notes
- Reload config: `prefix + r` (or `tmux source-file ~/.config/tmux/tmux.conf`)
- Debug options: `tmux show-options -g` / `tmux show-options -s`
- List bindings: `tmux list-keys`
- Check key conflicts: `tmux list-keys | grep <key>`
- Session save: `prefix + Ctrl-s` / restore: `prefix + Ctrl-r`
- URL picker: `prefix + u` (tmux-fzf-url default)
