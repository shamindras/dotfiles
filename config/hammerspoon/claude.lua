-- claude.lua — Claude Desktop deep links plus post-load focus
--
-- The desktop app (com.anthropic.claudefordesktop) handles claude:// URLs;
-- aerospace routes its window to workspace C. Two things the URL alone
-- cannot do, so this module drives the page through hs.axuielement after
-- navigation (same technique as nordvpn.lua):
--
--   * Recents hides its search box behind a magnifier button. After
--     `recents` loads, press the button so the cursor is ready to type.
--   * The Settings overlay (opened by `usage`) sits on top of the chat
--     surface and keeps keyboard focus, so a later `new` would land the
--     composer behind it. Every open() first dismisses that overlay, and
--     `new` then re-asserts focus on the composer, which the dismissal
--     otherwise leaves unfocused.
--
-- AX contract (verified against Claude 2.26454.2 — labels are the API):
--   AXButton    AXDescription "Search your activity"   Recents magnifier
--   AXTextField AXDescription "Search your activity"   Recents search box
--               (matched by description, not the "Search recents..."
--               placeholder, which vanishes once anything is typed)
--   AXTextArea  AXDescription "Write your prompt to Claude"  chat composer
--   AXTextField AXDescription "Search settings"         Settings overlay open
--   AXButton    AXDescription "Close"                   Settings overlay close
--
-- Traversal is a synchronous depth-first walk over AXChildren rooted at
-- the APPLICATION element, skipping the AXMenuBar children (~400
-- elements, ~50 ms). The root matters: Chromium turns its web
-- accessibility tree on lazily, and only a walk that reaches the window
-- through the application's AXChildren switches it on. A walk rooted at
-- the window itself (AXMainWindow, hs.window → windowElement) sees the
-- ~14 NSView-level elements forever. Once switched on, the tree fills in
-- over ~2 s, which the poll absorbs. hs.axuielement:elementSearch is not
-- used (5-8 s per pass from the app element).
--
-- Activation is a synthesized mouse click at the element's AXFrame
-- centre (mouse position restored). AXPress on Chromium's elements worked
-- in some sessions and was silently ignored in others, with no readable
-- state to tell the two apart; a click always lands. The same goes for
-- AXFocused writes, so a field that does not report focus after the
-- write is clicked too. AXManualAccessibility is never set: it is not
-- needed for the tree, and setting it on every poll rebuilt the tree
-- each time and left the window without a web tree for 40 s+ after a
-- cold launch.
--
-- Timing: act no sooner than SETTLE_S after a URL was sent, otherwise
-- the click lands on the outgoing page; and re-click the magnifier if
-- the search box has not appeared REPRESS_S later (a few tries).
--
-- Safety: a click is only sent while Claude is the frontmost app and the
-- target frame lies on a screen. aerospace parks other workspaces'
-- windows off-screen, so without the guard a leader fire followed by a
-- workspace switch would click blind into whatever is under that point.
-- If Claude stops being frontmost once the page is up, the poll is
-- abandoned: the user has moved on.
--
-- Cold start: the window exists before its web tree does, and the app's
-- own startup landing page can win over the deep link it was launched
-- with. So when the first poll sees no AXWebArea, the module waits for
-- one to appear, re-sends the link once, and polls on a longer budget.

local M = {}

-- Set `require('claude').debug = true` to record each step (with a
-- timestamp relative to open()) in _G._claude_log; read it back via
-- `hs -c "return table.concat(_G._claude_log, '\\n')"`. print() is unsafe
-- from timer callbacks reached through hs.ipc, so we accumulate instead.
M.debug = false
local t_open = 0
local function dbg(msg)
  if not M.debug then
    return
  end
  _G._claude_log = _G._claude_log or {}
  _G._claude_log[#_G._claude_log + 1] = string.format('+%.2fs %s', hs.timer.secondsSinceEpoch() - t_open, msg)
end

-- {{{ Constants

local BUNDLE = 'com.anthropic.claudefordesktop'

M.links = {
  new = 'claude://claude.ai/new?surface=chat',
  recents = 'claude://claude.ai/chat', -- no conversation id → /recents
  usage = 'claude://claude.ai/settings/usage',
  code_new = 'claude://code/new',
  code_last = 'claude://code/continue?session=last',
}

local MAGNIFIER = 'Search your activity' -- button and field share it
local COMPOSER = 'Write your prompt to Claude'
local SETTINGS_FIELD = 'Search settings'
local SETTINGS_CLOSE = 'Close'

local MAX_DEPTH = 40
local MAX_NODES = 4000
local POLL_S = 0.2
local SETTLE_S = 0.6 -- after a URL send, before pressing / focusing anything
local REPRESS_S = 1.5 -- re-press the magnifier if the box has not shown
local MAX_PRESSES = 3
local TIMEOUT_S = 10 -- warm: page is there within a poll or two
local COLD_TIMEOUT_S = 30 -- cold: launch + web tree + re-send + render
local COLD_RESEND_DELAY_S = 1.5 -- let the landing page settle before re-sending

-- }}}

-- {{{ AX helpers

local function claude_app()
  return hs.application.applicationsForBundleID(BUNDLE)[1]
end

local function app_element()
  local app = claude_app()
  if not app then
    dbg('no app')
    return nil
  end
  return hs.axuielement.applicationElement(app)
end

local function frontmost()
  local app = claude_app()
  return app ~= nil and app:isFrontmost()
end

local function on_screen(pt)
  for _, screen in ipairs(hs.screen.allScreens()) do
    if hs.geometry.point(pt):inside(screen:fullFrame()) then
      return true
    end
  end
  return false
end

-- Click the centre of an element's frame, then put the mouse back. Only
-- while Claude is frontmost and the point is on a screen (see header).
local function click(el)
  local f = el:attributeValue('AXFrame')
  if not f or f.w == 0 then
    return false
  end
  local pt = { x = f.x + f.w / 2, y = f.y + f.h / 2 }
  if not frontmost() or not on_screen(pt) then
    dbg('click skipped: claude not frontmost / target off-screen')
    return false
  end
  local prev = hs.mouse.absolutePosition()
  hs.eventtap.leftClick(pt)
  hs.mouse.absolutePosition(prev)
  return true
end

-- Focus a field: ask AX first, click it if that was ignored. Returns
-- whether the field reports focus afterwards.
local function focus(el)
  el:setAttributeValue('AXFocused', true)
  if el:attributeValue('AXFocused') then
    return true
  end
  click(el)
  return el:attributeValue('AXFocused') == true
end

-- Synchronous DFS from the application element (see header for why not
-- the window). Returns the first element matching pred (or nil) and
-- whether an AXWebArea was seen on the way, which tells a cold launch
-- apart from a loaded page.
local function find(pred)
  local root = app_element()
  if not root then
    return nil, false
  end
  local nodes, saw_web = 0, false
  local function walk(el, depth)
    if depth > MAX_DEPTH or nodes >= MAX_NODES then
      return nil
    end
    local role = el:attributeValue('AXRole')
    if role == 'AXMenuBar' then
      return nil
    end
    nodes = nodes + 1
    if role == 'AXWebArea' then
      saw_web = true
    end
    if pred(el) then
      return el
    end
    for _, child in ipairs(el:attributeValue('AXChildren') or {}) do
      local hit = walk(child, depth + 1)
      if hit then
        return hit
      end
    end
    return nil
  end
  return walk(root, 0), saw_web
end

local function is(role, attr, value)
  return function(el)
    return el:attributeValue('AXRole') == role and el:attributeValue(attr) == value
  end
end

-- }}}

-- {{{ Steps

-- If the Settings overlay is up, press its Close button. Detect by the
-- overlay's own search field so a stray "Close" elsewhere in the page is
-- never pressed.
local function dismiss_settings()
  if not find(is('AXTextField', 'AXDescription', SETTINGS_FIELD)) then
    return
  end
  local btn = find(is('AXButton', 'AXDescription', SETTINGS_CLOSE))
  if btn and click(btn) then
    dbg('clicked settings Close')
  end
end

-- Poll until `field` exists and is focused, focusing it ourselves once it
-- shows. If `button` is given and the field is not there yet, press the
-- button once (Recents keeps its search box collapsed behind the
-- magnifier). On a cold start (first poll sees no AXWebArea) wait for the
-- web tree, re-send `link` once, and extend the budget. Gives up silently
-- when the budget runs out (page never loaded, or labels changed upstream).
local poll_timer

local function stop_poll()
  if poll_timer then
    poll_timer:stop()
    poll_timer = nil
  end
end

local function focus_field(link, field, button)
  stop_poll()
  local started = hs.timer.secondsSinceEpoch()
  local sent_at = started -- last URL send; nothing is pressed before +SETTLE_S
  local budget = TIMEOUT_S
  local presses = 0
  local pressed_at = nil
  local overlay_closes = 0
  local cold = nil -- unknown until the first poll completes
  local web_seen_at = nil
  local resent = false
  poll_timer = hs.timer.doEvery(POLL_S, function()
    local now = hs.timer.secondsSinceEpoch()
    if now - started > budget then
      dbg('focus poll timed out')
      stop_poll()
      return
    end
    if cold and web_seen_at and not resent and now - web_seen_at > COLD_RESEND_DELAY_S then
      resent = true
      presses, pressed_at = 0, nil
      sent_at = now
      dbg('cold start: web tree up, re-sending url')
      hs.urlevent.openURL(link)
      return
    end
    -- The magnifier may be pressed again if the box has not shown up.
    local may_press = button ~= nil and presses < MAX_PRESSES and (pressed_at == nil or now - pressed_at > REPRESS_S)
    local el, saw_web = find(function(el)
      return field(el) or (may_press and button(el))
    end)
    if cold == nil then
      cold = not saw_web
      if cold then
        budget = COLD_TIMEOUT_S
        dbg('cold start detected (no web tree yet)')
      end
    end
    if saw_web and not web_seen_at then
      web_seen_at = now
      dbg('web tree visible')
    end
    -- Until the cold-start re-send has gone out, anything we find belongs
    -- to the landing page the app is about to replace.
    if cold and not resent then
      return
    end
    if now - sent_at < SETTLE_S then
      return
    end
    if not frontmost() then
      dbg('abandoned: claude no longer frontmost')
      stop_poll()
      return
    end
    -- An overlay that survived the pre-send dismissal (its Close was
    -- clicked mid-transition) still sits over the page: close it first.
    if overlay_closes < MAX_PRESSES and find(is('AXTextField', 'AXDescription', SETTINGS_FIELD)) then
      local btn = find(is('AXButton', 'AXDescription', SETTINGS_CLOSE))
      if btn and click(btn) then
        overlay_closes = overlay_closes + 1
        dbg('clicked lingering settings Close (' .. overlay_closes .. ')')
      end
      return
    end
    if not el then
      return
    end
    if el:attributeValue('AXRole') == 'AXButton' then
      click(el)
      presses = presses + 1
      pressed_at = now
      dbg('clicked button (' .. presses .. ')')
      return
    end
    local focused = focus(el)
    dbg('field found, focused=' .. tostring(focused))
    if focused then
      stop_poll()
    end
  end)
end

local FOCUS = {
  recents = {
    field = is('AXTextField', 'AXDescription', MAGNIFIER),
    button = is('AXButton', 'AXDescription', MAGNIFIER),
  },
  new = { field = is('AXTextArea', 'AXDescription', COMPOSER) },
}

-- }}}

-- {{{ Public

-- Cancel an in-flight focus poll (debugging aid).
function M.stop()
  stop_poll()
end

-- open('new' | 'recents' | 'usage' | 'code_new' | 'code_last')
-- Dismiss the Settings overlay if present, open the deep link (launches
-- the app when it is not running), then run the per-route focus step
-- (FOCUS): recents → search box, new → composer. usage focuses its own
-- search box; the Code tab routes need nothing.
function M.open(name)
  local link = M.links[name]
  if not link then
    error('claude.open: unknown route ' .. tostring(name))
  end
  t_open = hs.timer.secondsSinceEpoch()
  _G._claude_log = {}
  dbg('open ' .. name)
  dismiss_settings()
  hs.urlevent.openURL(link)
  local f = FOCUS[name]
  if f then
    focus_field(link, f.field, f.button)
  end
end

-- }}}

return M
