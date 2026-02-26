# Karabiner-Elements Configuration

## Overview

Karabiner-Elements remaps modifier keys for Vim-friendly ergonomics. Three
dual-function rules: Caps Lock and Left Control become Escape on tap / Control
on hold; Right Command sends Fn+F12 on tap.

- **Docs**: https://karabiner-elements.pqrs.org/docs/
- **Installed version**: karabiner-elements 15.9.0 (verified 2026-02-26)

## File Structure

| File                         | Purpose                                    |
| ---------------------------- | ------------------------------------------ |
| `karabiner.json`             | Main config: rules, devices, profile       |
| `assets/complex_modifications/` | For imported rules (currently empty)    |
| `automatic_backups/`         | Managed by Karabiner-Elements              |

## Key Remapping Rules

All rules use `"type": "basic"` with `to_if_alone` dual-function logic:

| From Key         | Held (modifier) | Tapped (alone)  | Purpose                       |
| ---------------- | --------------- | --------------- | ----------------------------- |
| `caps_lock`      | `left_control`  | `escape`        | Vim-friendly: Esc on tap      |
| `left_control`   | `left_control`  | `escape`        | Redundant Esc source          |
| `right_command`   | `right_command` | `Fn+F12`        | Function key on tap           |

All use `"lazy": true` — modifier not sent until another key is pressed.
All use `"modifiers": {"optional": ["any"]}` — works with any held modifier.

## Global Parameters

| Parameter                                | Value | Effect                           |
| ---------------------------------------- | ----- | -------------------------------- |
| `basic.to_if_alone_timeout_milliseconds` | 200   | Tap window (release within 200ms)|
| `basic.to_if_held_down_threshold_milliseconds` | 75 | Hold detection threshold     |

## Device Configuration

Two device entries:
1. **Specific external device** (`c7-93-17-97-50-a0`): keyboard+pointing, LED off
2. **Generic keyboard fallback**: catches all other keyboards, LED off

The MAC address entry is hardware-specific — may not match on a new machine.

## Development Notes

- Changes apply via Karabiner-Elements GUI or app restart
- Validate: Karabiner validates JSON on startup; invalid syntax prevents loading
- Test: Preferences GUI shows rule loading status
- `manipulate_caps_lock_led: false` prevents LED flicker
- Profile: single "Default profile" with `ansi` virtual HID keyboard
