# SketchyBar Configuration

- **Docs**: https://github.com/FelixKratz/SketchyBar
- **Installed version**: Run `sketchybar --version` to check

## Structure

```
config/sketchybar/
├── sketchybarrc          # Main config: bar, defaults, items, bracket pills
├── colors.sh             # Catppuccin Mocha palette + pill colors (ARGB hex)
├── items/                # Item definitions (what to show)
│   ├── workspace.sh      # Aerospace workspace + app name (left)
│   ├── front_app.sh      # Focused application tracker (left, hidden label)
│   ├── clock.sh          # Date/time (right)
│   ├── battery.sh        # Battery icon + percentage (right)
│   ├── wifi.sh           # WiFi icon (right)
│   └── volume.sh         # Volume icon (right)
├── plugins/              # Plugin scripts (how to update)
│   ├── workspace.sh      # Handles aerospace_workspace_change event
│   ├── front_app.sh      # Handles front_app_switched, triggers workspace refresh
│   ├── clock.sh          # Polls date command
│   ├── battery.sh        # Polls pmset for battery info
│   ├── wifi.sh           # Polls system_profiler for WiFi status
│   ├── volume.sh         # Polls osascript for volume level
│   ├── wake_refresh.sh   # Guards system_woke → sketchybar --update
│   └── toggle_bar.sh     # Toggles between sketchybar and native menu bar
└── CLAUDE.md             # This file
```

## Conventions

### General
- Items define *what* to show (position, font, colors, subscriptions)
- Plugins define *how* to update (the script that runs on events/timers)
- Colors use Catppuccin Mocha palette in ARGB hex format (`0xAARRGGBB`)
- Font: JetBrains Mono Nerd Font (consistent with terminal configs)
- Bar uses transparent background with `blur_radius=20` for frosted glass effect
- `sticky=on` + `topmost=on` keeps bar visible on all workspaces
- **Bracket pills** group items into rounded pill-shaped backgrounds
  - `left_pill`: wraps workspace label
  - `right_pill`: wraps volume, wifi, battery, clock
- **Toggle** (`Alt+Shift+.`): keybinding-driven script that switches between
  sketchybar and native menu bar (not event-subscribed)
- Workspace updates via Aerospace's `exec-on-workspace-change` event
- Plugin scripts (standalone) must include `set -Eeuo pipefail` (repo convention)
- Item scripts are sourced into `sketchybarrc` — do **not** add strict mode

### Wake Refresh

A central `wake_refresh` item in `sketchybarrc` subscribes to `system_woke` and
runs `sketchybar --update` to force all items to re-execute their plugin scripts.
This prevents stale data (clock, battery, wifi, etc.) after waking from sleep.
The clock additionally subscribes to `display_change` to catch lid-open scenarios
that may not trigger a full sleep/wake cycle.

| Item           | Event subscriptions                                  |
| -------------- | ---------------------------------------------------- |
| wake_refresh   | `system_woke` (forces global `--update`)             |
| clock          | `display_change`                                     |
| battery        | `power_source_change`                                |
| wifi           | `wifi_change`                                        |
| volume         | `volume_change`                                      |
| workspace      | `aerospace_workspace_change` (custom)                |
| front_app      | `front_app_switched`                                 |

## Service Management

Sketchybar runs as a **brew service** via launchd (`RunAtLoad` + `KeepAlive`),
not via AeroSpace's `exec-and-forget`. This ensures reliable startup at login
and automatic restart on crash.

| Command                          | Effect                              |
| -------------------------------- | ----------------------------------- |
| `brew services start sketchybar` | Register + start the launchd agent  |
| `brew services stop sketchybar`  | Stop + unregister the launchd agent |
| `brew services info sketchybar`  | Show running/loaded status          |
| `sketchybar --reload`            | Reload config (process must be up)  |

- **Log paths**: `~/Library/Logs/Homebrew/sketchybar/`
- **Plist**: `~/Library/LaunchAgents/homebrew.mxcl.sketchybar.plist`
- **Brewfile**: `restart_service: :changed` restarts the service on formula upgrade
- **Nvim autocmd**: saving `sketchybarrc`, `colors.sh`, or `items/*.sh` triggers
  `sketchybar --reload` via `BufWritePost` in `config/nvim/lua/shamindras/core/autocmds.lua`

## Theme Management

sketchybar uses inline ARGB hex colors in shell scripts. No external theme
files or import system.

- **Canonical palette**: `colors.sh` (Catppuccin Mocha in `0xAARRGGBB` format)
- **Change theme**: replace hex values in `colors.sh`, then `sketchybar --reload`
- All items source `colors.sh` — changing it propagates to the entire bar
