# Kanata Configuration

- **Docs**: https://github.com/jtroo/kanata
- **Config docs**: https://github.com/jtroo/kanata/blob/main/docs/config.adoc
- **Installed version**: kanata 1.11.0 (built from source with `cmd` feature)

## Overview

Cross-platform keyboard remapper replacing Karabiner-Elements (tap-hold
remaps) and Leader Key (leader sequences for app launching, quitting,
URLs, and utilities). Runs as a launchd daemon with root privileges.

## File Structure

| File                      | Purpose                                            |
| ------------------------- | -------------------------------------------------- |
| `kanata.kbd`              | Main config: defcfg, defsrc, deflayer, includes    |
| `aliases-base.kbd`        | 3 dual-function key remaps (tap-hold)              |
| `sequences.kbd`           | All ~40 leader sequences (defvirtualkeys + defseq) |
| `com.jtroo.kanata.plist`  | launchd daemon config (runs as root)               |

## Key Settings

### defcfg

| Setting                 | Value               | Purpose                                    |
| ----------------------- | ------------------- | ------------------------------------------ |
| `danger-enable-cmd`     | `yes`               | Enable shell command execution              |
| `sequence-timeout`      | `2000`              | 2s window to complete leader sequences      |
| `sequence-input-mode`   | `hidden-suppressed` | Keys consumed during sequence (not typed)   |
| `process-unmapped-keys` | `yes`               | Pass unmapped keys through to OS            |

### Tap-hold remaps (from Karabiner-Elements)

| Key           | Tap      | Hold          | Timing               |
| ------------- | -------- | ------------- | -------------------- |
| Caps Lock     | Escape   | Left Control  | 200ms tap, 200ms hold |
| Left Control  | Escape   | Left Control  | 200ms tap, 200ms hold |
| Right Command | `sldr`   | Right Command | 200ms tap, 200ms hold |

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

### Leader sequences (from Leader Key)

Trigger: Right Command tap → `sldr` (sequence leader mode) → type 2-key
sequence within 2s timeout.

| Group | Key | Actions                                            |
| ----- | --- | -------------------------------------------------- |
| `c`   | 3   | Claude URLs (recents, new chat, usage)             |
| `o`   | 16  | Open apps (via `fastopen` helper)                  |
| `q`   | 16  | Quit apps (via `quit-app` helper + workspace switch)|
| `r`   | 9   | Run utilities (brew, notifications, files, etc.)   |
| `s`   | 3   | Search Raycast (bookmarks, clipboard, files)       |
| `g`   | 5   | GitHub URLs (repos, profile)                       |
| `u`   | 4   | Personal URLs (blog, homepage, YouTube, Keep)      |

## Cross-Tool References

- **run-as-user** (`config/bin/run-as-user`): Root→user context switch (used by all scripts and inline sequences)
- **fastopen** (`config/bin/fastopen`): Centralized app launcher with path lookup
- **quit-app** (`config/bin/quit-app`): Graceful quit + workspace switch
- **open-nordvpn** (`config/bin/open-nordvpn`): NordVPN multi-step launch
- **brew-update** (`config/bin/brew-update`): Brew update/upgrade in WezTerm window
- **empty-trash** (`config/bin/empty-trash`): Empty Finder trash + workspace switch
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
