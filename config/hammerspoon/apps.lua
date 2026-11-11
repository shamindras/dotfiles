-- apps.lua — open/quit leader groups and HUD labels from resolved.json
--
-- The app registry lives in manifest.json; scripts/ops/manifest renders it
-- per profile into generated/<profile>/resolved.json, which install links to
-- ~/.config/dotfiles/resolved.json. This module reads that one fixed path and
-- never asks which profile it is running under.
--
-- M.build is pure (no hs.* calls) so it can be tested headless with plain
-- lua: scripts/test/check-hammerspoon feeds it both profiles' resolved.json.
-- M.load wraps it for Hammerspoon: a missing or malformed file gives empty
-- open/quit groups (extras still bound) plus a visible alert.

local M = {}

-- {{{ Pure builder

local QUIT_IDLE = 10000

local function sh_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

-- Letters first, then digits (the HUD's reading order).
local function key_order(a, b)
  local ad, bd = a:match('%d') ~= nil, b:match('%d') ~= nil
  if ad ~= bd then
    return bd
  end
  return a < b
end

---Build the open and quit groups for a resolved profile.
---@param resolved table|nil decoded resolved.json (nil = no registry)
---@param opts table { bin = fn(cmd) -> string, as_user = fn(cmd) -> string,
---  extras = { open = {binding...}, quit = {binding...} } } where an extra
---  binding is { key, label, cmd, icon?, idle? }
---@return table open_bindings, table quit_bindings, string open_hud, string quit_hud
function M.build(resolved, opts)
  local open, quit = {}, {}
  local open_icons, quit_icons = {}, {}
  local leaders = resolved and resolved.leaders or {}
  local units = resolved and resolved.units or {}

  for key, name in pairs(leaders) do
    local unit = units[name]
    local app = unit and unit.app
    if app then
      local open_cmd
      if app.open_command then
        open_cmd = opts.as_user(app.open_command)
      else
        open_cmd = opts.bin('fastopen ' .. sh_quote(app.path))
        if app.fullscreen then
          open_cmd = open_cmd .. ' --fullscreen ' .. app.fullscreen
        end
        if app.return_workspace then
          open_cmd = open_cmd .. ' --return ' .. app.return_workspace
        end
      end
      table.insert(open, { key = key, label = app.label or name, cmd = open_cmd })

      local quit_cmd = 'quit-app ' .. sh_quote(app.process or name) .. ' ' .. (app.quit_workspace or 'B')
      if app.quit_check then
        quit_cmd = quit_cmd .. ' --check ' .. app.quit_check .. ' --fallback ' .. (app.quit_fallback or 'B')
      end
      if app.quit_save_check then
        quit_cmd = quit_cmd .. ' --save-check ' .. app.quit_save_check
      end
      table.insert(quit, {
        key = key,
        label = app.quit_label or app.process or name,
        cmd = opts.bin(quit_cmd),
        idle = QUIT_IDLE,
      })
      open_icons[key] = app.icon or '?'
      quit_icons[key] = app.icon or '?'
    end
  end

  local extras = opts.extras or {}
  for _, b in ipairs(extras.open or {}) do
    table.insert(open, { key = b.key, label = b.label, cmd = b.cmd })
    open_icons[b.key] = b.icon or '?'
  end
  for _, b in ipairs(extras.quit or {}) do
    table.insert(quit, { key = b.key, label = b.label, cmd = b.cmd, idle = b.idle or QUIT_IDLE })
    quit_icons[b.key] = b.icon or '?'
  end

  local function sort(list)
    table.sort(list, function(a, b)
      return key_order(a.key, b.key)
    end)
  end
  sort(open)
  sort(quit)

  local function hud(prefix, list, icons)
    local parts = { prefix }
    for _, b in ipairs(list) do
      table.insert(parts, b.key .. ':' .. icons[b.key])
    end
    return table.concat(parts, ' ')
  end

  return open, quit, hud('(o)▸', open, open_icons), hud('(q)▸', quit, quit_icons)
end

-- }}}

-- {{{ Hammerspoon loader

local function registry_path()
  local fixed = os.getenv('HOME') .. '/.config/dotfiles/resolved.json'
  if hs.fs.attributes(fixed) then
    return fixed
  end
  -- transitional: until ./install links ~/.config/dotfiles on this Mac (the
  -- move to ~/repos, node N16), read the home render next to this config.
  local real = hs.fs.pathToAbsolute(hs.configdir)
  return real and (real .. '/../../generated/home/resolved.json') or fixed
end

---Read resolved.json and build the groups; never throws.
function M.load(opts)
  local path = registry_path()
  local ok, resolved = pcall(hs.json.read, path)
  if not ok or type(resolved) ~= 'table' or type(resolved.leaders) ~= 'table' then
    hs.alert.show('leader: no app registry at ' .. path .. ' (open/quit groups empty)', 6)
    resolved = nil
  end
  return M.build(resolved, opts)
end

-- }}}

return M
