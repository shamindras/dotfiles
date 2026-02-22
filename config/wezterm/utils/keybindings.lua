-- {{{ Boilerplate & Helpers

local M = {}
local wezterm = require('wezterm')
local act = wezterm.action

--- tmux prefix key sent before every tmux_key. Change here to update all bindings.
local TMUX_PREFIX = { mods = 'CTRL', key = 'a' }

--- Send CMD+key as tmux prefix (C-a) followed by tmux_key.
--- WezTerm intercepts CMD before it reaches the terminal, translates
--- it into the tmux prefix sequence so tmux handles the action.
---@param key string  WezTerm key to bind (with CMD modifier)
---@param tmux_key string  Key to send after the tmux prefix
---@return table
local function tmux(key, tmux_key)
  return {
    key = key,
    mods = 'CMD',
    action = act.Multiple({
      act.SendKey(TMUX_PREFIX),
      act.SendKey({ key = tmux_key }),
    }),
  }
end

--- Same as tmux() but with CMD+SHIFT modifier.
---@param key string  WezTerm key to bind (with CMD+SHIFT modifier)
---@param tmux_key string  Key to send after the tmux prefix
---@return table
local function tmux_shift(key, tmux_key)
  return {
    key = key,
    mods = 'CMD|SHIFT',
    action = act.Multiple({
      act.SendKey(TMUX_PREFIX),
      act.SendKey({ key = tmux_key }),
    }),
  }
end

--- Open a new WezTerm window in the current pane's working directory.
local spawn_window_cwd = wezterm.action_callback(function(window, pane)
  local cwd_url = pane:get_current_working_dir()
  local args = {}
  if cwd_url then
    args.cwd = cwd_url.file_path
  end
  window:perform_action(act.SpawnCommandInNewWindow(args), pane)
end)

-- ------------------------------------------------------------------------- }}}

-- {{{ Key Bindings

---@param config table
---@return table
function M.setup(config)
  -- Mouse bindings
  config.mouse_bindings = {
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CMD',
      action = act.OpenLinkAtMouseCursor,
    },
  }

  -- stylua: ignore start
  config.keys = {
    -- Pane management
    tmux('d', '|'),                -- CMD+D       = split right
    tmux_shift('D', '-'),          -- CMD+Shift+D = split down
    tmux('w', 'x'),                -- CMD+W       = close pane
    tmux('m', 'z'),                -- CMD+M       = toggle zoom

    -- Window management
    tmux('t', 'c'),                -- CMD+T       = new window
    tmux_shift('W', '&'),          -- CMD+Shift+W = close window
    tmux('h', 'p'),                -- CMD+H       = previous window
    tmux('l', 'n'),                -- CMD+L       = next window
    tmux_shift('H', '<'),          -- CMD+Shift+H = swap window left
    tmux_shift('L', '>'),          -- CMD+Shift+L = swap window right
    tmux_shift('E', ','),          -- CMD+Shift+E = rename window
    tmux('1', '1'),                -- CMD+1       = window 1
    tmux('2', '2'),                -- CMD+2       = window 2
    tmux('3', '3'),                -- CMD+3       = window 3
    tmux('4', '4'),                -- CMD+4       = window 4
    tmux('5', '5'),                -- CMD+5       = window 5
    tmux('6', '6'),                -- CMD+6       = window 6
    tmux('7', '7'),                -- CMD+7       = window 7
    tmux('8', '8'),                -- CMD+8       = window 8
    tmux('9', '9'),                -- CMD+9       = window 9

    -- Session management
    tmux('k', 's'),                -- CMD+K       = sesh picker
    tmux('s', 'w'),                -- CMD+S       = session/window tree
    tmux('j', 'L'),                -- CMD+J       = last session
    tmux('n', 'S'),                -- CMD+N       = new session

    -- Copy mode
    tmux('[', '['),                -- CMD+[       = enter copy mode

    -- Utilities
    tmux('g', 'g'),                -- CMD+G       = lazygit
    tmux_shift('B', '!'),          -- CMD+Shift+B = break pane to window
    tmux_shift('R', 'r'),          -- CMD+Shift+R = reload tmux config

    -- WezTerm-native (not tmux passthrough)
    { key = 'N', mods = 'CMD|SHIFT', action = spawn_window_cwd }, -- CMD+Shift+N = new window (same cwd)
    {                              -- ALT+Enter   = disabled
      key = 'Enter',
      mods = 'ALT',
      action = act.DisableDefaultAssignment,
    },
  }
  -- stylua: ignore end

  return config
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Module Export

return M

-- ------------------------------------------------------------------------- }}}
