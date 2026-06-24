# Hammerspoon Configuration

- **Docs**: <https://www.hammerspoon.org/docs/>
- **GitHub**: <https://github.com/Hammerspoon/hammerspoon>
- **Installed version**: Hammerspoon 1.1.1 (verified via `brew info hammerspoon`)

## Overview

Userspace keyboard remapper + modal leader system covering tap-hold
remaps, the right-cmd leader sequence, and Caps→F18 at the HID layer.

Hammerspoon requires only an Accessibility grant — no root, no
kernel extension, no DriverKit. The most defensive escape hatch
on a fully-frozen keyboard is SSH-from-phone (see `RECOVERY.md`).

## File Structure

```text
config/hammerspoon/
├── CLAUDE.md
├── init.lua                                # entry; requires leader + taphold
├── leader.lua                              # hs.hotkey.modal scaffold + idle timer
├── taphold.lua                             # 4 tap-hold remaps via hs.eventtap
├── hud.lua                                 # SketchyBar leader HUD bridge
├── actions.lua                             # ~60-action data table (7 groups)
└── launchagents/
    └── com.local.hidutil-remap.plist       # Caps→F18 + F1..F12→media at login
```

## XDG location

Hammerspoon defaults to `~/.hammerspoon/`. The project is symlinked
to `$XDG_CONFIG_HOME/hammerspoon/` (the entire directory) by
`install.conf.yaml`. The actual config path is overridden via:

```sh
defaults write org.hammerspoon.Hammerspoon MJConfigFile \
  "$XDG_CONFIG_HOME/hammerspoon/init.lua"
```

This is set by `scripts/setup/setup-hammerspoon` and is the only
mechanism (Hammerspoon discussion [#3730](https://github.com/Hammerspoon/hammerspoon/discussions/3730)).
The `defaults write` must happen BEFORE Hammerspoon first reads its
config; the setup script enforces ordering.

## Tap-hold remaps (taphold.lua)

| Physical key  | Tap (<200ms, no chord)  | Hold                                    |
| ------------- | ----------------------- | --------------------------------------- |
| Caps Lock     | Escape                  | Left Control (synth'd via flag event)   |
| Left Control  | Escape                  | Left Control (natural)                  |
| Right Command | Enter leader modal      | Right Command (natural)                 |
| Right Option  | Right Option (natural)  | nav layer (ROpt+Bspc → ForwardDelete)   |

Implementation notes:

- **Caps Lock** is invisible to `hs.eventtap` at the firmware level.
  The companion LaunchAgent (`com.local.hidutil-remap.plist`) remaps
  it to **F18** via `hidutil`; `taphold.lua` intercepts F18 instead.
- For F18 we synthesize a `ctrl` flag-change event on key-down/up so
  chord-style usage (F18 + letter) still presents as LCtrl + letter
  to downstream apps.
- The three real modifiers (LCtrl, RCmd, ROpt) propagate naturally
  during the hold; only the tap action is synthesized.
- `hs.eventtap.checkKeyboardModifiers(true)` is used to distinguish
  L/R sides — `event:getFlags()` collapses both into a single bit.
- A `hs.usb.watcher` re-kickstarts the LaunchAgent on every USB
  attach/detach to mitigate documented hidutil drift on long uptime
  (amarsyla/hidutil-key-remapping-generator [#3](https://github.com/amarsyla/hidutil-key-remapping-generator/issues/3)).

## Leader system (leader.lua + actions.lua)

`hs.hotkey.modal` scaffold with one modal for the leader layer and
one per sub-group. `hs.timer.doAfter` arms an idle-exit (2 s default,
10 s for `quit` actions so SketchyBar's quit notification has room
to surface).

| Group  | Key | Count | Purpose                                          |
| ------ | --- | ----- | ------------------------------------------------ |
| open   | o   | 17    | Launch apps via `config/bin/fastopen`            |
| quit   | q   | 17    | Quit apps via `config/bin/quit-app` (10s idle)   |
| claude | c   | 3     | Claude URLs                                      |
| run    | r   | 9     | Run utilities (brew, trash, mute, …)             |
| search | s   | 3     | Raycast extensions                               |
| github | g   | 5     | GitHub URLs                                      |
| urls   | u   | 5     | Personal URLs                                    |

State transitions:

- F18 tap (Caps) and RCmd tap both call `leader.enter_leader()`.
- Group entry: `leader → sub-group`, HUD updates, idle timer re-arms.
- Action fires: `sub-group → base`, HUD hides, shell command runs in
  a detached `hs.task` so a slow process can't trap the modal.
- Escape from sub-group → back to leader.
- Escape from leader → exit + HUD hides.
- Any unbound letter in any modal → exit + HUD hides (fail-safe).
- 2 s idle at any level → exit + HUD hides.

### Cross-tool contracts

Hammerspoon shells out to these scripts with the argv they expect:

- `config/bin/{fastopen, quit-app, leader-hud, brew-update,
  empty-trash, open-nordvpn, run-as-user, close-notifications}`
- `config/sketchybar/items/leader.sh` + the
  `leader-hud show | hide <group>` interface
- Group names recognised by the HUD (`leader`, `open`, `quit`,
  `claude`, `run`, `search`, `github`, `urls`)

The TextEdit quit leaf (`quit → q`) passes `--save-check Q`: if the
document has unsaved changes, `quit-app` switches to TextEdit's own
workspace `Q` (where aerospace assigns it) and fires the quit there, so
the save dialog shows on-screen instead of off on Firefox's workspace
`W`. Once the dialog resolves, it switches to `W` if TextEdit actually
quit, or stays on `Q` if cancelled.

## hidutil LaunchAgent

`launchagents/com.local.hidutil-remap.plist` is symlinked to
`~/Library/LaunchAgents/` by dotbot. `RunAtLoad=true`, no `KeepAlive`
(hidutil is one-shot — a `KeepAlive` would crash-loop).

Payload remaps (v1):

- **Caps Lock → F18** — the only mapping included today. Required
  so `taphold.lua` can intercept the Caps tap-hold via `hs.eventtap`
  (firmware Caps Lock is invisible to event taps).

F-row remaps (F1–F12 → media keys) are **deliberately not included**
in v1. The Apple-vendor codes for Spotlight, Dictation, and Do Not
Disturb are not reliably mappable through `hidutil`'s standard
`UserKeyMapping` schema. macOS's native F-row behaviour covers most
of the parity (brightness, Mission Control, prev/play/next, mute,
volume); add specific entries once the exact codes are verified on
the installed macOS version (Apple TN2450 + `hidutil property --get
UserKeyMapping`).

`hs.usb.watcher` re-fires the agent on USB attach/detach (see
taphold.lua). On long-uptime drift, a manual nudge is also:

```sh
launchctl kickstart -k "gui/$(id -u)/com.local.hidutil-remap"
```

## Reload

| Trigger                                     | Effect                                       |
| ------------------------------------------- | -------------------------------------------- |
| Save any `config/hammerspoon/*.lua` in nvim | `hs -c "hs.reload()"` (BufWritePost autocmd) |
| Manual reload                               | `hs -c "hs.reload()"`                        |
| `RCmd → r → r` (leader: run → reload-hs)    | `hs.reload()`                                |

`hs.reload()` is in-process — no daemon, no sudo, no password prompt,
no SecureInput-while-typing risk.

## Persistence across reboot

All of the following survive reboot automatically:

- **Hammerspoon auto-launches** — `hs.autoLaunch(true)` in `init.lua`
  registers a macOS Login Item. `scripts/setup/setup-hammerspoon`
  asserts the same via the `hs` CLI as belt-and-suspenders, in case
  `init.lua` hasn't loaded yet (Accessibility grant pending).
- **Caps → F18 mapping** — `com.local.hidutil-remap` LaunchAgent has
  `RunAtLoad=true` and re-applies the `hidutil` property at every login.
  It's a one-shot setter, so `launchctl print` showing
  `state = not running` is normal — `hidutil` exits after applying.
- **XDG config path** — the `defaults write org.hammerspoon.Hammerspoon
  MJConfigFile …` value persists in user defaults.
- **Accessibility grant** — sits in the per-user macOS TCC database.
- **eventtaps (leader + tap-hold)** — re-installed by `init.lua` on
  every Hammerspoon launch (which the auto-launch entry triggers).

## Manual setup steps (cannot be automated)

- **Accessibility grant**: System Settings → Privacy & Security →
  Accessibility → enable Hammerspoon. Required to capture key events.
  Granted once; survives Hammerspoon upgrades.
- **fn key behaviour**: System Settings → Keyboard → "Press 🌐 key to" →
  set to **Do Nothing** (default is "Show Emoji & Symbols", which
  hijacks the fn key). Required for native `fn + Backspace →
  ForwardDelete`.

## Hammerspoon API surfaces used

`hs.hotkey.modal`, `hs.timer.doAfter`, `hs.eventtap`,
`hs.eventtap.event.newKeyEvent`, `hs.eventtap.checkKeyboardModifiers`,
`hs.eventtap.keyStroke`, `hs.usb.watcher`, `hs.task`, `hs.notify`,
`hs.keycodes.map`.

Validate field names against the installed version's docs before
adding new code paths — Hammerspoon renames between point releases
(field renames in `hs.hotkey.modal` happened between 0.9 → 1.0).
