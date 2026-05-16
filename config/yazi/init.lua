-- Yazi startup hook (~/.config/yazi/init.lua, auto-loaded at launch).
--
-- Reads two env vars set by sesh's `sesh_window_yazi_tabs` helper:
--   YAZI_STARTUP_TABS  colon-separated list of absolute paths to open as
--                      additional tabs after the initial WORK_DIR tab.
--   YAZI_ACTIVE_TAB    0-based index of the tab to activate (default: 0).
-- Paths must not contain ':' since that is the field separator.
local startup_tabs = os.getenv('YAZI_STARTUP_TABS')
if startup_tabs and startup_tabs ~= '' then
  for path in string.gmatch(startup_tabs, '[^:]+') do
    ya.emit('tab_create', { path })
  end
  local active = tonumber(os.getenv('YAZI_ACTIVE_TAB') or '0') or 0
  if active > 0 then
    ya.emit('tab_switch', { active })
  end
end
