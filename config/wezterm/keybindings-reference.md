# WezTerm Keybindings Reference

Source of truth: `utils/keybindings.lua`. Update this file whenever bindings
change.

## Modifier Layers

| Layer | Modifier    | Scope                         |
| ----- | ----------- | ----------------------------- |
| L0    | CMD         | Pane / window actions         |
| L1    | CMD+SHIFT   | Modify / destructive / create |
| L2    | CMD+CTRL    | Session scope                 |

All tmux bindings send prefix `C-a` followed by the tmux key. Key-table
bindings send prefix + table key + action key (e.g., `C-a O g` for lazygit).

## Pane Management

| WezTerm key     | tmux key | Action               |
| --------------- | -------- | -------------------- |
| `CMD+D`         | `\|`     | Split right          |
| `CMD+SHIFT+D`   | `-`      | Split down           |
| `CMD+W`         | `x`      | Close pane           |
| `CMD+M`         | `z`      | Toggle zoom          |
| `CMD+;`         | `;`      | Last pane            |
| `CMD+O`         | `C-o`    | Rotate panes         |
| `CMD+E`         | `E`      | Equalize panes       |
| `CMD+SHIFT+B`   | `!`      | Break pane to window |

## Pane Resize

| WezTerm key        | tmux key  | Action         |
| ------------------ | --------- | -------------- |
| `CMD+SHIFT+Left`   | `M-Left`  | Resize left 5  |
| `CMD+SHIFT+Right`  | `M-Right` | Resize right 5 |
| `CMD+SHIFT+Up`     | `M-Up`    | Resize up 5    |
| `CMD+SHIFT+Down`   | `M-Down`  | Resize down 5  |

## Window Management

| WezTerm key     | tmux key | Action            |
| --------------- | -------- | ----------------- |
| `CMD+T`         | `c`      | New window (after current) |
| `CMD+SHIFT+W`   | `&`      | Close window      |
| `CMD+H`         | `p`      | Previous window   |
| `CMD+L`         | `n`      | Next window       |
| `CMD+SHIFT+H`   | `<`      | Swap window left  |
| `CMD+SHIFT+L`   | `>`      | Swap window right |
| `CMD+SHIFT+E`   | `,`      | Rename window     |
| `CMD+0`         | `a`      | Last window       |
| `CMD+1-9`       | `1-9`    | Window by number  |

## Session Management — N (Navigate) key table

| WezTerm key     | tmux key | Action              |
| --------------- | -------- | ------------------- |
| `CMD+K`         | `N w`    | Session/window tree |
| `CMD+SHIFT+K`   | `N s`    | Sesh picker         |
| `CMD+J`         | `N j`    | Last session        |
| `CMD+N`         | `N n`    | New session         |
| `CMD+CTRL+H`    | `N h`    | Previous session    |
| `CMD+CTRL+L`    | `N l`    | Next session        |
| `CMD+CTRL+E`    | `N e`    | Rename session      |
| `CMD+CTRL+W`    | `N k`    | Kill session        |

## Tool Launchers — O (Open) key table

| WezTerm key     | tmux key | Action                  |
| --------------- | -------- | ----------------------- |
| `CMD+G`         | `O g`    | Lazygit popup           |
| `CMD+Y`         | `O y`    | Yazi                    |
| `CMD+I`         | `O i`    | Items (taskwarrior-tui) |
| `CMD+B`         | `O b`    | Btm                     |
| `CMD+SHIFT+C`   | `O c`    | Claude Code split       |
| `CMD+U`         | `O u`    | fzf-url picker          |

## Copy Mode & Utilities

| WezTerm key     | tmux key | Action             |
| --------------- | -------- | ------------------ |
| `CMD+[`         | `[`      | Enter copy mode    |
| `CMD+SHIFT+R`   | `r`      | Reload tmux config |

## WezTerm-native (no tmux passthrough)

| WezTerm key     | Action                        |
| --------------- | ----------------------------- |
| `CMD+SHIFT+N`   | New WezTerm window (same cwd) |
| `ALT+Enter`     | Disabled                      |

## Mouse Bindings

| Input       | Action              |
| ----------- | ------------------- |
| `CMD+Click` | Open link at cursor |
