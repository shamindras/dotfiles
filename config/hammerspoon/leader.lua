-- leader.lua — modal leader-key scaffold
--
--   Right Cmd tap (via taphold.lua) or F18 tap (Caps via hidutil)
--     → leader modal
--       → group modal (o/q/c/r/s/g/u)
--         → action → exec shell + return to base
--
-- Semantics:
--   * 2s idle at any modal level → return to base + hide HUD
--   * Quit-group actions arm a 10s idle override (see actions.lua) so the
--     sketchybar quit notification has room to surface
--   * Escape from a sub-group → back to leader (HUD re-shows "leader")
--   * Escape from leader      → return to base + hide HUD
--   * Any unbound letter in a sub-group → return to base + hide HUD (fail-safe)

local actions = require('actions')
local hud = require('hud')

local M = {}

-- Set to true to log every modal transition + idle expiry to a global
-- table. print() inside eventtap callbacks deadlocks via hs.ipc
-- recursion, so we accumulate to _G._leader_log instead; pull via
-- `hs -c "return table.concat(_G._leader_log, '\\n')"`.
local DEBUG = false
local function dbg(msg)
  if not DEBUG then
    return
  end
  _G._leader_log = _G._leader_log or {}
  if #_G._leader_log < 60 then
    table.insert(_G._leader_log, string.format('[leader %.3f] %s', hs.timer.secondsSinceEpoch() % 1000, msg))
  end
end

-- {{{ Modal state

local leader_modal -- hs.hotkey.modal — entered on F18 tap
local group_modals = {} -- name → hs.hotkey.modal
local idle_timer -- hs.timer.doAfter handle

local DEFAULT_IDLE_MS = 2000
-- ASCII a-z (no symbols, no digits beyond the leader-level "1"). Each modal
-- binds these explicitly so any non-action key returns the user to base
-- with the HUD hidden, rather than silently swallowing the press.
local LETTERS = {}
for c = string.byte('a'), string.byte('z') do
  LETTERS[#LETTERS + 1] = string.char(c)
end

-- }}}

-- {{{ Idle timer

local function cancel_idle()
  if idle_timer then
    idle_timer:stop()
    idle_timer = nil
  end
end

local function arm_idle(ms, on_expire)
  cancel_idle()
  idle_timer = hs.timer.doAfter(ms / 1000, function()
    idle_timer = nil
    on_expire()
  end)
end

-- }}}

-- {{{ Base / leader / group transitions

local function to_base(reason)
  dbg('to_base reason=' .. tostring(reason))
  cancel_idle()
  if leader_modal then
    leader_modal:exit()
  end
  for _, m in pairs(group_modals) do
    m:exit()
  end
  hud.hide()
end

local function to_leader(from_sub)
  dbg('to_leader from_sub=' .. tostring(from_sub))
  cancel_idle()
  if from_sub then
    for _, m in pairs(group_modals) do
      m:exit()
    end
  end
  leader_modal:enter()
  hud.show('leader')
  arm_idle(DEFAULT_IDLE_MS, function()
    to_base('idle-expire')
  end)
end

local function enter_group(spec)
  dbg('enter_group name=' .. tostring(spec.name))
  cancel_idle()
  leader_modal:exit()
  local m = group_modals[spec.name]
  m:enter()
  hud.show(spec.name)
  arm_idle(DEFAULT_IDLE_MS, function()
    to_base('idle-expire-group')
  end)
end

local function fire_action(action)
  dbg('fire_action label=' .. tostring(action.label))
  cancel_idle()
  -- Exit modal *before* shelling out so a slow command can't trap the
  -- modal in a half-state.
  for _, m in pairs(group_modals) do
    m:exit()
  end
  hud.hide()
  -- /bin/sh -c lets actions.lua chain commands via ' ; '.
  hs.task
    .new('/bin/sh', nil, function()
      return false
    end, { '-c', action.cmd })
    :start()
end

-- }}}

-- {{{ Modal construction

local function build_group_modal(spec)
  local m = hs.hotkey.modal.new()
  local bound = {}

  for _, action in ipairs(spec.bindings) do
    bound[action.key] = true
    m:bind({}, action.key, function()
      -- Quit actions need a longer post-fire idle so sketchybar quit
      -- notifications don't get stomped. Re-arming here is normally moot
      -- because fire_action exits the modal, but kept in case future
      -- actions stay in-modal.
      cancel_idle()
      if action.idle then
        arm_idle(action.idle, to_base)
      end
      fire_action(action)
    end)
  end

  -- Escape → back to leader.
  m:bind({}, 'escape', function()
    to_leader(true)
  end)

  -- Every other letter → fail-safe return to base.
  for _, letter in ipairs(LETTERS) do
    if not bound[letter] then
      m:bind({}, letter, function()
        to_base('sub-modal unbound key=' .. letter)
      end)
    end
  end

  return m
end

local function build_leader_modal()
  local m = hs.hotkey.modal.new()
  local bound = {}

  for _, spec in ipairs(actions.leader_groups) do
    bound[spec.key] = true
    m:bind({}, spec.key, function()
      enter_group(spec)
    end)
  end

  -- Escape from leader → return to base.
  m:bind({}, 'escape', function()
    to_base('leader-modal escape')
  end)

  -- Every other letter in the leader layer → return to base.
  for _, letter in ipairs(LETTERS) do
    if not bound[letter] then
      m:bind({}, letter, function()
        to_base('leader-modal unbound key=' .. letter)
      end)
    end
  end

  return m
end

-- }}}

-- {{{ Public entry points

-- Called from taphold.lua when Right Cmd is tapped. The hidutil LaunchAgent
-- maps Caps Lock → F18 (used for the Caps tap-hold), but the leader trigger
-- comes through the Right Cmd tap-hold detector. We expose enter_leader so
-- taphold.lua does not need to know about modals.
function M.enter_leader()
  to_leader(false)
end

function M.setup()
  leader_modal = build_leader_modal()
  for _, spec in ipairs(actions.leader_groups) do
    group_modals[spec.name] = build_group_modal(spec.target)
  end
end

-- Exposed for hs.reload() integration tests and human debugging from the
-- hs.console REPL.
M._to_base = to_base
M._enter_group = enter_group

-- }}}

return M
