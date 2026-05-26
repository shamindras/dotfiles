-- hud.lua — SketchyBar leader HUD bridge
--
-- Wraps the `config/bin/leader-hud show|hide <group>` interface. Group
-- names recognised by config/sketchybar/items/leader.sh / config/bin/leader-hud:
--   leader, open, quit, claude, run, search, github, urls

local M = {}

local LEADER_HUD = os.getenv('HOME') .. '/.config/bin/leader-hud'

-- Run the bin script in the background so a slow sketchybar call cannot
-- block the modal scaffold. hs.task is async, hs.execute would block.
-- The script's PATH is set inside leader-hud itself (hs.task gives
-- subprocesses the minimal default PATH that does not include
-- /opt/homebrew/bin, so sketchybar would otherwise exit 127).
local function fire(args)
  hs.task
    .new(LEADER_HUD, nil, function()
      return false
    end, args)
    :start()
end

function M.show(group)
  fire({ 'show', group })
end

function M.hide()
  fire({ 'hide' })
end

return M
