-- init.lua — Hammerspoon entry point
--
-- See config/hammerspoon/CLAUDE.md for the architecture overview.
--
-- Lives at $XDG_CONFIG_HOME/hammerspoon/init.lua via the
-- `defaults write org.hammerspoon.Hammerspoon MJConfigFile ...`
-- step in scripts/setup/setup-hammerspoon (Hammerspoon has no
-- documented XDG support; this defaults key is the only mechanism).

-- Quieten the modal "alert" pop when entering/exiting hs.hotkey.modal.
hs.hotkey.alertDuration = 0

-- Surface unhandled errors to the console rather than the system log.
hs.crash.crashLogToNSLog = false

-- Allow `package.path` to find sibling modules without a full path.
package.path = hs.configdir .. '/?.lua;' .. package.path

-- Enable the `hs` command-line tool so external callers can drive
-- reloads (`hs -c "hs.reload()"`) and inspection. Required by:
--   * config/nvim/.../autocmds.lua BufWritePost hammerspoon/*.lua reload
--   * actions.lua leader `r → r` (reload-hs)
--   * Module G verification commands
require('hs.ipc')

-- Auto-launch at login. Idempotent — Hammerspoon registers itself in
-- macOS Login Items via the AddLoginItem private API and skips when
-- already present. Asserted on every config load so a user-side toggle
-- in the Hammerspoon Preferences pane can't silently drift out of sync
-- with this repo.
hs.autoLaunch(true)

local leader = require('leader')
local taphold = require('taphold')

leader.setup()
taphold.setup()

-- Tiny confirmation that reload completed — visible feedback after the
-- nvim BufWritePost reload or a manual `hs -c "hs.reload()"`.
hs.notify
  .new({
    title = 'Hammerspoon',
    informativeText = 'Config loaded',
    autoWithdraw = true,
    withdrawAfter = 1,
  })
  :send()
