# SketchyBar Configuration

- **Docs**: https://github.com/FelixKratz/SketchyBar
- **Installed version**: Run `sketchybar --version` to check

## Structure

```
config/sketchybar/
├── sketchybarrc          # Main config: bar props, defaults, sources items
├── colors.sh             # Catppuccin Mocha palette (ARGB hex)
├── items/                # Item definitions (what to show)
│   ├── workspace.sh      # Aerospace workspace indicator (left)
│   ├── front_app.sh      # Focused application name (left)
│   ├── clock.sh          # Date/time (right)
│   ├── battery.sh        # Battery percentage + state (right)
│   └── wifi.sh           # WiFi SSID/status (right)
├── plugins/              # Plugin scripts (how to update)
│   ├── workspace.sh      # Handles aerospace_workspace_change event
│   ├── front_app.sh      # Handles front_app_switched event
│   ├── clock.sh          # Polls date command
│   ├── battery.sh        # Polls pmset for battery info
│   └── wifi.sh           # Polls networksetup for WiFi info
└── CLAUDE.md             # This file
```

## Conventions

- Items define *what* to show (position, font, colors, subscriptions)
- Plugins define *how* to update (the script that runs on events/timers)
- Colors use Catppuccin Mocha palette in ARGB hex format (`0xAARRGGBB`)
- Font: JetBrains Mono Nerd Font (consistent with terminal configs)
- Bar is fully transparent (`0x00000000`) — no blur, no background
- Workspace updates via Aerospace's `exec-on-workspace-change` event
