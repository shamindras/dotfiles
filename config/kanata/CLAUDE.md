# Kanata Configuration

- **Docs**: https://github.com/jtroo/kanata
- **Config docs**: https://github.com/jtroo/kanata/blob/main/docs/config.adoc
- **Installed version**: kanata 1.11.0 (built from source with `cmd` feature)

## Overview

Cross-platform keyboard remapper replacing Karabiner-Elements (tap-hold
remaps) and Leader Key (leader sequences for app launching, quitting,
URLs, and utilities). Runs as a launchd daemon with root privileges.

## File Structure

| File                     | Purpose                                             |
| ------------------------ | --------------------------------------------------- |
| `kanata.kbd`             | Main config: defcfg, defsrc, deflayer, includes     |
| `layers.kbd`             | Leader layer system (fakekeys, aliases, 8 deflayers)|
| `aliases-base.kbd`       | 3 dual-function key remaps (tap-hold)               |
| `sequences.kbd.bak`      | Archived original sequences (rollback reference)    |
| `com.jtroo.kanata.plist` | launchd daemon config (runs as root)                |

## Key Settings

### defcfg

| Setting                 | Value | Purpose                        |
| ----------------------- | ----- | ------------------------------ |
| `danger-enable-cmd`     | `yes` | Enable shell command execution |
| `process-unmapped-keys` | `yes` | Pass unmapped keys through     |

### defsrc (39 keys)

Captures caps, lctl, rmet, f1-f12, esc, 1, and 22 letters
(a b c d e f g h i k m n o p q r s t u v w x). Letters are needed for
the leader layer system. In the default layer, all letters/numbers/esc
map to themselves (passthrough).

Keys NOT in defsrc (j, l, y, z, 2-9, etc.) pass through via
`process-unmapped-keys` and are invisible to layers.

### Tap-hold remaps (from Karabiner-Elements)

| Key           | Tap      | Hold          | Timing                |
| ------------- | -------- | ------------- | --------------------- |
| Caps Lock     | Escape   | Left Control  | 200ms tap, 200ms hold |
| Left Control  | Escape   | Left Control  | 200ms tap, 200ms hold |
| Right Command | `@ldr`   | Right Command | 200ms tap, 200ms hold |

### F-row media key mappings

macOS media key translation is bypassed by kanata's virtual keyboard
(see kanata #975, #1141). F-row keys are explicitly mapped to media
codes so brightness/volume/etc. work.

**fn key limitation**: The Apple `fn` key is firmware-level and
invisible to kanata — it cannot be intercepted or used as a modifier.
`fn+F-key` does NOT produce raw F1–F12; it still triggers the media
mapping. Raw F-keys are unavailable unless a spare key is designated
as an fn-toggle for a `(layer-toggle fn-raw)` layer.

| Key | Media Function  | Kanata code |
| --- | --------------- | ----------- |
| f1  | Brightness Down | `brdn`      |
| f2  | Brightness Up   | `brup`      |
| f3  | Mission Control | `mctl`      |
| f4  | Spotlight       | `sls`       |
| f5  | Dictation       | `dtn`       |
| f6  | Do Not Disturb  | `_`         |
| f7  | Media Previous  | `prev`      |
| f8  | Play/Pause      | `pp`        |
| f9  | Media Next      | `next`      |
| f10 | Mute            | `mute`      |
| f11 | Volume Down     | `vold`      |
| f12 | Volume Up       | `volu`      |

### Leader layer system

Trigger: Right Command tap → leader layer → group layer → action key → base.

**Architecture**: 8 `deflayer` blocks (1 leader + 7 sub-layers) in
`layers.kbd`. Each layer transition fires a shell command to update a
SketchyBar HUD item via `leader-hud`. Idle timeout returns to base
after 2s via `on-idle-fakekey`.

**Flow**:
- RCmd tap → `@ldr` → enters leader layer + shows HUD + arms 2s idle timer
- Group key (o/q/c/r/s/g/u) → enters sub-layer + updates HUD
- Action key → fires command + returns to base + hides HUD
- Escape in sub-layer → back to leader (true backspace)
- Escape in leader → return to base + hide HUD
- 2s idle at any level → auto-return to base + hide HUD
- Unmatched key in sub-layer → return to base + hide HUD (fail-safe)

**Alias conventions** (in `layers.kbd`):

| Prefix | Purpose                                | Count |
| ------ | -------------------------------------- | ----- |
| `ldr`  | Enter leader layer (from rmc tap)      | 1     |
| `sl-*` | Enter sub-layer (leader → group)       | 7     |
| `bkl`  | Back to leader (escape in sub-layer)   | 1     |
| `bas`  | Return to base + hide HUD              | 1     |
| `ao-*` | Open app actions                       | 16    |
| `aq-*` | Quit app actions                       | 16    |
| `ac-*` | Claude URL actions                     | 3     |
| `ar-*` | Run utility actions                    | 9     |
| `as-*` | Search Raycast actions                 | 3     |
| `ag-*` | GitHub URL actions                     | 5     |
| `au-*` | Personal URL actions                   | 4     |

| Group | Key | Actions                                             |
| ----- | --- | --------------------------------------------------- |
| `o`   | 16  | Open apps (via `fastopen` helper)                   |
| `q`   | 16  | Quit apps (via `quit-app` helper + workspace switch) |
| `c`   | 3   | Claude URLs (recents, new chat, usage)              |
| `r`   | 9   | Run utilities (brew, notifications, files, etc.)    |
| `s`   | 3   | Search Raycast (bookmarks, clipboard, files)        |
| `g`   | 5   | GitHub URLs (repos, profile)                        |
| `u`   | 4   | Personal URLs (blog, homepage, YouTube, Keep)       |

## Cross-Tool References

- **leader-hud** (`config/bin/leader-hud`): SketchyBar leader HUD updater (show/hide group labels)
- **run-as-user** (`config/bin/run-as-user`): Root→user context switch (used by leader-hud and other scripts)
- **fastopen** (`config/bin/fastopen`): Centralized app launcher with path lookup
- **quit-app** (`config/bin/quit-app`): Graceful quit + workspace switch
- **open-nordvpn** (`config/bin/open-nordvpn`): NordVPN multi-step launch
- **brew-update** (`config/bin/brew-update`): Brew update/upgrade in WezTerm window
- **empty-trash** (`config/bin/empty-trash`): Empty Finder trash + workspace switch
- **sketchybar**: Leader HUD item (`items/leader.sh`, left-aligned) updated by `leader-hud` script
- **aerospace**: Quit commands switch to designated workspace after quitting
- **nvim**: BufWritePost autocmd restarts kanata daemon on `*.kbd` save

## Installation

Setup script `scripts/setup-upgrade-kanata` handles everything:
1. Builds kanata from source with `cmd` feature (Homebrew lacks it)
2. Copies plist to `/Library/LaunchDaemons/` and loads/restarts daemon
3. Stops conflicting Karabiner-Elements services (keeps VirtualHIDDevice driver)

Run automatically as part of `./install`.

## launchd Daemon

Plist: `com.jtroo.kanata.plist` → copied to
`/Library/LaunchDaemons/com.jtroo.kanata.plist` by setup script.

```bash
# Restart (after config changes)
sudo launchctl kickstart -k system/com.jtroo.kanata

# Unload
sudo launchctl unload /Library/LaunchDaemons/com.jtroo.kanata.plist

# Logs
tail -f /tmp/kanata.stdout.log
tail -f /tmp/kanata.stderr.log
```

## Manual Setup (cannot be automated)

- **Input Monitoring**: System Settings → Privacy & Security → Input Monitoring →
  add `~/.local/share/cargo/bin/kanata` (required for keyboard interception,
  TCC/SIP protected — cannot be scripted)

## Development Notes

- Requires Karabiner VirtualHIDDevice driver on macOS
- All `cmd` calls use `/bin/sh -c` for minimal shell overhead
- Kanata runs as root — `HOME` is set to `/Users/shamindras` in the plist
- Live reload: `lrld` action reloads config (device settings NOT reloaded)
- Full restart: `sudo launchctl kickstart -k system/com.jtroo.kanata`
- Syntax check: `kanata --check --cfg kanata.kbd`
- Include order matters: `layers.kbd` before `aliases-base.kbd` (alias dependencies)
