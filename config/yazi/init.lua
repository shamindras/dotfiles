-- Yazi startup hook (~/.config/yazi/init.lua, auto-loaded at launch).

-- Custom linemode: file size followed by mtime ("12.9M  06/02 18:47").
-- Selected via [mgr].linemode = "size_and_mtime" in yazi.toml.
-- Directories (no intrinsic size) show only mtime.
function Linemode:size_and_mtime()
  local time = math.floor(self._file.cha.mtime or 0)
  local time_str = time > 0 and os.date('%m/%d %H:%M', time) or ''
  local size = self._file:size()
  if size then
    return ui.Line(string.format(' %s  %s ', ya.readable_size(size), time_str))
  else
    return ui.Line(string.format(' %s ', time_str))
  end
end

-- Reads two env vars set by `~/.config/bin/yazi-tabs` (the single
-- launcher used by the zsh `yt` function, tmux `prefix O y`, and sesh's
-- `sesh_window_yazi_tabs` helper):
--   YAZI_STARTUP_TABS  colon-separated list of absolute paths to open as
--                      additional tabs after the initial WORK_DIR tab.
--   YAZI_ACTIVE_TAB    0-based index of the tab to activate (default: 0).
-- Paths must not contain ':' since that is the field separator.
local startup_tabs = os.getenv('YAZI_STARTUP_TABS')
if startup_tabs and startup_tabs ~= '' then
  for path in string.gmatch(startup_tabs, '[^:]+') do
    ya.emit('tab_create', { path })
  end
  -- tab_create focuses each new tab, so always switch back to the
  -- requested tab — including 0 (the cwd tab).
  local active = tonumber(os.getenv('YAZI_ACTIVE_TAB') or '0') or 0
  ya.emit('tab_switch', { active })
end
