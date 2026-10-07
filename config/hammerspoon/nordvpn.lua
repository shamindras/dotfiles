-- nordvpn.lua — pause / resume NordVPN through its accessibility tree
--
-- NordVPN 10.x (sideload build) ships no CLI, no AppleScript dictionary
-- and no documented nordvpn:// actions for connection control, but its
-- main window exposes stable AXIdentifiers. Pressing them via
-- hs.axuielement works without focusing the window — no workspace
-- switch, no focus steal.
--
-- Identifiers (verified against NordVPN 10.12.0):
--   connectionCardImmediatePauseButton  "Pause for 15 min"     connected only
--   connectionCardActionButton          "Secure my connection" paused OR disconnected
--   toastHeader                         AXValue "Paused", AXDescription
--                                       "VPN connection resumes in mm:ss"  paused only
--
-- Driven by config/bin/nordvpn-pause via `hs -c`. Every entry point must
-- return well under a second — hs.ipc times out around 3 s — so this
-- module only presses and reads; the shell side polls for the new state.

local M = {}

-- {{{ Constants

local APP = 'NordVPN'
local ID_PAUSE = 'connectionCardImmediatePauseButton'
local ID_ACTION = 'connectionCardActionButton'
local ID_TOAST = 'toastHeader'
local MAX_DEPTH = 14

-- }}}

-- {{{ AX scan

-- Walk the main window once and collect the three elements we care
-- about, keyed by identifier. Scoped to the window (not the app element)
-- so the menubar / recents subtrees are never traversed.
local function scan()
  local app = hs.application.get(APP)
  if not app then
    return nil, 'not-running'
  end
  local win = app:mainWindow() or app:allWindows()[1]
  if not win then
    return nil, 'no-window'
  end
  local found = {}
  local function walk(el, depth)
    if depth > MAX_DEPTH then
      return
    end
    local kids = el:attributeValue('AXChildren')
    if not kids then
      return
    end
    for _, k in ipairs(kids) do
      local id = k:attributeValue('AXIdentifier')
      if id == ID_PAUSE or id == ID_ACTION or id == ID_TOAST then
        found[id] = k
      end
      walk(k, depth + 1)
    end
  end
  local root = hs.axuielement.windowElement(win)
  -- Cap per-query AX wait so a busy NordVPN can't stall Hammerspoon's
  -- main thread (and with it every other hs.ipc caller).
  pcall(function()
    root:setTimeout(1)
  end)
  walk(root, 0)
  return found
end

-- The toast splits its text across attributes: AXValue carries the
-- header ("Paused"), AXDescription the countdown ("VPN connection resumes
-- in 14:57"). Join every non-empty string so callers can match either.
local function toast_text(found)
  local t = found[ID_TOAST]
  if not t then
    return ''
  end
  local parts = {}
  for _, attr in ipairs({ 'AXTitle', 'AXValue', 'AXDescription' }) do
    local v = t:attributeValue(attr)
    if type(v) == 'string' and v ~= '' then
      parts[#parts + 1] = v
    end
  end
  return table.concat(parts, ' / ')
end

local function classify(found)
  if found[ID_PAUSE] then
    return 'connected'
  end
  if found[ID_ACTION] then
    local toast = toast_text(found)
    if toast:match('resumes in') or toast:match('^Paused') then
      return 'paused'
    end
    return 'disconnected'
  end
  return 'unknown'
end

-- }}}

-- {{{ Public API

-- → not-running | no-window | connected | paused | disconnected | unknown
function M.state()
  local found, err = scan()
  if not found then
    return err
  end
  return classify(found)
end

-- → "mm:ss" left on the pause timer, or '' when not paused.
function M.remaining()
  local found = scan()
  if not found then
    return ''
  end
  return toast_text(found):match('(%d+:%d+)') or ''
end

-- Press the 15-minute pause button. → 'pausing' on press, else the
-- current state (so callers can explain why nothing happened).
function M.pause()
  local found, err = scan()
  if not found then
    return err
  end
  local st = classify(found)
  if st ~= 'connected' then
    return st
  end
  found[ID_PAUSE]:performAction('AXPress')
  return 'pausing'
end

-- Press the resume button. → 'resuming' on press, else the current state.
function M.resume()
  local found, err = scan()
  if not found then
    return err
  end
  local st = classify(found)
  if st ~= 'paused' then
    return st
  end
  found[ID_ACTION]:performAction('AXPress')
  return 'resuming'
end

-- connected → pause, paused → resume, anything else → report state.
function M.toggle()
  local found, err = scan()
  if not found then
    return err
  end
  local st = classify(found)
  if st == 'connected' then
    found[ID_PAUSE]:performAction('AXPress')
    return 'pausing'
  elseif st == 'paused' then
    found[ID_ACTION]:performAction('AXPress')
    return 'resuming'
  end
  return st
end

-- }}}

return M
