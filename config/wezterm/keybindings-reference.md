# WezTerm Keybindings Reference

Source of truth: `utils/keybindings.lua`. Update this file whenever bindings
change.

## Modifier Layers

| Layer | Modifier    | Scope                         |
| ----- | ----------- | ----------------------------- |
| L0    | CMD         | Pane / window actions         |
| L1    | CMD+SHIFT   | Modify / destructive / create |
| L2    | CMD+CTRL    | Session scope                 |

All tmux bindings send prefix `C-a` followed by the tmux key.

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
| `CMD+SHIFT+C`   | `b`      | Claude Code split    |

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
| `CMD+T`         | `c`      | New window        |
| `CMD+SHIFT+W`   | `&`      | Close window      |
| `CMD+H`         | `p`      | Previous window   |
| `CMD+L`         | `n`      | Next window       |
| `CMD+SHIFT+H`   | `<`      | Swap window left  |
| `CMD+SHIFT+L`   | `>`      | Swap window right |
| `CMD+SHIFT+E`   | `,`      | Rename window     |
| `CMD+0`         | `a`      | Last window       |
| `CMD+1-9`       | `1-9`    | Window by number  |

## Session Management

| WezTerm key     | tmux key | Action              |
| --------------- | -------- | ------------------- |
| `CMD+K`         | `s`      | Sesh picker         |
| `CMD+S`         | `w`      | Session/window tree |
| `CMD+J`         | `L`      | Last session        |
| `CMD+N`         | `S`      | New session         |
| `CMD+CTRL+H`    | `(`      | Previous session    |
| `CMD+CTRL+L`    | `)`      | Next session        |
| `CMD+CTRL+E`    | `$`      | Rename session      |
| `CMD+CTRL+W`    | `X`      | Kill session        |

## Copy Mode & Tools

| WezTerm key     | tmux key | Action             |
| --------------- | -------- | ------------------ |
| `CMD+[`         | `[`      | Enter copy mode    |
| `CMD+P`         | `P`      | Popup shell        |
| `CMD+G`         | `g`      | Lazygit popup      |
| `CMD+Y`         | `F`      | Yazi popup         |
| `CMD+U`         | `u`      | fzf-url picker     |
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
