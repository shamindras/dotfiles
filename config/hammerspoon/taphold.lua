-- taphold.lua — dual-function key remaps
--
-- Three tap-hold pairs, all at a 200 ms threshold:
--   Caps Lock  → Esc on tap / LCtrl on hold
--   LCtrl      → Esc on tap / LCtrl on hold
--   RCmd       → leader on tap / RCmd on hold (release-decided)
--
-- Caps Lock is invisible to hs.eventtap at the firmware layer, so the
-- companion LaunchAgent (config/hammerspoon/launchagents/com.local.hidutil-remap.plist)
-- maps Caps → F18 at the HID layer. This module intercepts F18 instead.
--
-- For the F18 "hold = LCtrl" chord, posting a synthetic LCtrl keypress via
-- hs.eventtap.event.newKeyEvent does NOT reliably update macOS's modifier
-- flag state (the synthetic event is delivered but apps don't see
-- "ctrl-held"). Instead, while F18 is held, we mutate the flags of every
-- subsequent key event in-place via event:setFlags() — apps see Ctrl+key
-- with the correct modifier bits.
--
-- The LCtrl / RCmd remaps target real modifier keys, so the OS handles
-- their "hold" behaviour natively; we only synthesise the tap action on
-- quick release with no interleaved keypress.
--
-- macOS emits ForwardDelete natively for fn+Backspace once the "Press 🌐
-- key to" preference is set to "Do Nothing" (System Settings → Keyboard),
-- so no nav-layer is needed for that.

local leader = require('leader')

local M = {}

-- {{{ Constants

local TAP_THRESHOLD = 0.2 -- 200 ms

local KC = hs.keycodes.map

-- Apple virtual keycodes for the modifier keys we track manually. Using
-- these directly is more reliable than hs.eventtap.checkKeyboardModifiers,
-- whose raw field names (`deviceLeftControl` / `deviceRightCommand` / etc.)
-- vary across Hammerspoon versions. For flagsChanged events the event's
-- own keycode identifies which modifier toggled — unambiguous, side-aware.
local MOD = {
  RCMD = 54,
  LCTRL = 59,
}

-- }}}

-- {{{ Shared state

-- F18 (= Caps via hidutil) tap-hold. Held → mutate flags of subsequent
-- key events to add ctrl. Quick release with no interleave → emit Esc.
local f18_down_time = nil
local f18_interleaved = false

-- LCtrl tap-on-release
local lctrl_down_time = nil
local lctrl_interleaved = false

-- RCmd tap-on-release (triggers leader on tap)
local rcmd_down_time = nil
local rcmd_interleaved = false

-- Hot taps so :start()/:stop() survives hs.reload()
local taps = {}

-- }}}

-- {{{ Helpers

local function now()
  return hs.timer.secondsSinceEpoch()
end

local function held_for(t)
  return t and (now() - t) or math.huge
end

-- }}}

-- {{{ keyDown / keyUp handler

local function handle_keyio(event)
  local code = event:getKeyCode()
  local typ = event:getType()
  local isDown = (typ == hs.eventtap.event.types.keyDown)

  -- F18 (Caps Lock proxy): tap-hold for Esc on tap, virtual Ctrl on hold.
  -- Always suppress the F18 keycode itself — apps shouldn't see it.
  if code == KC.f18 then
    if isDown then
      -- Squash autorepeat: holding Caps should not spam our state machine.
      if event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat) > 0 then
        return true
      end
      f18_down_time = now()
      f18_interleaved = false
    else
      if f18_down_time and not f18_interleaved and held_for(f18_down_time) < TAP_THRESHOLD then
        hs.eventtap.keyStroke({}, 'escape', 0)
      end
      f18_down_time = nil
    end
    return true
  end

  -- F18-held chord injection: mutate this event's flags to add ctrl so
  -- downstream apps see Ctrl+key. setFlags() returns the event mutated
  -- in place — returning false below lets the (now-ctrl-flagged) event
  -- propagate normally.
  if f18_down_time then
    if isDown then
      f18_interleaved = true
    end
    local flags = event:getFlags()
    flags.ctrl = true
    event:setFlags(flags)
  end

  -- Interleave tracking for real-modifier tap-on-release (keyDown only).
  if isDown then
    if lctrl_down_time then
      lctrl_interleaved = true
    end
    if rcmd_down_time then
      rcmd_interleaved = true
    end
  end

  return false
end

-- }}}

-- {{{ flagsChanged: LCtrl + RCmd tap detection

local function handle_flags(event)
  -- The flagsChanged event's own keycode tells us exactly which modifier
  -- changed — unambiguous, side-aware, and immune to field-name drift
  -- across Hammerspoon versions. Our own `*_down_time` / `*_held` state
  -- tells us whether the transition was a press (state nil/false) or a
  -- release (state set/true).
  local code = event:getKeyCode()

  -- Left Ctrl tap-on-release → Esc
  if code == MOD.LCTRL then
    if not lctrl_down_time then
      lctrl_down_time = now()
      lctrl_interleaved = false
    else
      if not lctrl_interleaved and held_for(lctrl_down_time) < TAP_THRESHOLD then
        hs.eventtap.keyStroke({}, 'escape', 0)
      end
      lctrl_down_time = nil
    end
    return false
  end

  -- Right Cmd tap-on-release → enter leader
  if code == MOD.RCMD then
    if not rcmd_down_time then
      rcmd_down_time = now()
      rcmd_interleaved = false
    else
      if not rcmd_interleaved and held_for(rcmd_down_time) < TAP_THRESHOLD then
        leader.enter_leader()
      end
      rcmd_down_time = nil
    end
    return false
  end

  return false
end

-- }}}

-- {{{ USB watcher: re-issue hidutil mapping on hot-plug

-- hidutil settings do not always survive long uptimes or USB hot-plug
-- (see https://github.com/amarsyla/hidutil-key-remapping-generator/issues/3).
-- The LaunchAgent only fires at login, so we re-kickstart on every USB
-- attach/detach as belt-and-suspenders.
local function refresh_hidutil()
  hs.task
    .new('/bin/launchctl', nil, function()
      return false
    end, { 'kickstart', '-k', 'gui/' .. hs.host.uuid() .. '/com.local.hidutil-remap' })
    :start()
end

-- }}}

-- {{{ Public setup

function M.setup()
  -- Single eventtap covering both keyDown + keyUp so F18-held chord
  -- injection can mutate flags on the matching keyUp too (some apps
  -- watch keyUp modifier state).
  taps.keyio = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp,
  }, handle_keyio)

  taps.flags = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, handle_flags)

  taps.keyio:start()
  taps.flags:start()

  taps.usb = hs.usb.watcher.new(refresh_hidutil)
  taps.usb:start()
end

-- }}}

return M
