# config/archive/

Tool configs that have been replaced by newer alternatives but kept on disk
for historical reference and emergency rollback. Each migration is layered
chronologically — every entry below was once the canonical config under
`config/<tool>/` and is now superseded.

## Archived Packages

| Directory     | Was replaced by                  | Original purpose                              | Migration commit  |
| ------------- | -------------------------------- | --------------------------------------------- | ----------------- |
| `karabiner/`  | `config/kanata/` (tap-hold)      | Keyboard remapping (caps→esc/ctrl, etc.)      | `a5f8d15`         |
| `leader-key/` | `config/kanata/` (sequences)     | App launcher with hierarchical menus          | `a5f8d15`         |
| `kanata/`     | `config/hammerspoon/` (userspace)| Tap-hold + leader system (root LaunchDaemon)  | this PR (Phase 3) |

## Why kanata was archived (the most recent migration)

macOS 26 Tahoe reproducibly froze the keyboard when the Karabiner
DriverKit dext (a transitive dependency of kanata) activated. Recovery
required reinstalling macOS in the worst case, since even wired USB
keyboards were locked out at the IOHID layer. The version mismatch
between `karabiner-elements 16.0.0` (dext v6.14.0) and `kanata 1.11.0`
(pinned to dext v6.2.0) made the existing setup permanently non-viable
on Tahoe.

The replacement, Hammerspoon, is a userspace `.app` requiring only an
Accessibility grant — no LaunchDaemon, no dext, no kernel-adjacent risk.

See `RECOVERY.md` at the repo root for the rescue procedure if the
keyboard ever wedges again during a future migration; see the plan at
`.claude/plans/glowing-tumbling-thacker.md` for the full Phase 1/2/3
migration breakdown.

## Reverting kanata → Hammerspoon (back to kanata)

**This is strongly discouraged.** kanata's dependency on the Karabiner
DriverKit dext is the exact failure mode the migration escaped. If you
re-enable kanata on macOS 26+ you should expect the original
keyboard-freeze incidents to recur. Documented here for completeness
only.

### 1. Stop Hammerspoon

```sh
osascript -e 'tell application "Hammerspoon" to quit'
defaults delete org.hammerspoon.Hammerspoon MJConfigFile 2>/dev/null || true
launchctl bootout "gui/$(id -u)/com.local.hidutil-remap" 2>/dev/null || true
rm -f ~/Library/LaunchAgents/com.local.hidutil-remap.plist
```

### 2. Restore kanata config

```sh
git mv config/archive/kanata config/kanata
```

### 3. Reinstall Karabiner-Elements + kanata

```sh
brew install --cask karabiner-elements
cargo install kanata --features "default,cmd"
```

Then re-run `scripts/setup/setup-upgrade-kanata` if it has been
restored from git history, or recreate the LaunchDaemons manually
from `config/kanata/com.jtroo.kanata*.plist`.

### 4. Reverse the Phase 3 repo edits

Revert the relevant commit(s) on `chore/decommission-kanata-karabiner`,
or manually:

- `config/brew/Brewfile` — re-add `cask "karabiner-elements"`
- `install.conf.yaml` — re-add kanata symlink + `setup-upgrade-kanata` runner
- `CLAUDE.md` (root) — restore kanata rows in the supported-apps and
  tool-reload tables; drop the Hammerspoon tool-reload row
- `scripts/CLAUDE.md` — restore the kanata Login Items entry
- `config/nvim/lua/shamindras/core/autocmds.lua` — re-add the
  `*.kbd` BufWritePost autocmd that kickstarts kanata
- `scripts/setup/post-install-hints` — re-add kanata Input Monitoring
  reminder

### 5. Re-grant Input Monitoring for kanata

System Settings → Privacy & Security → Input Monitoring → add
`~/.local/share/cargo/bin/kanata`.

## Reverting kanata → karabiner + leader-key (older migration)

Pre-kanata, the same functionality was split across Karabiner-Elements
(tap-hold remaps) and Leader Key (app launcher menus). To restore that
era — possible but undocumented since the kanata migration commit
`a5f8d15` — combine the kanata-revert steps above (to remove
Hammerspoon) with the older karabiner+leader-key restore steps that
lived in this file prior to Phase 3. See git history for the original
revert checklist.
