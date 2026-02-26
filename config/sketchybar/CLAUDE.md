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
