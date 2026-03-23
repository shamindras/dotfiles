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

--- Same as tmux() but with CMD+CTRL modifier (session-scope layer).
---@param key string  WezTerm key to bind (with CMD+CTRL modifier)
---@param tmux_key string  Key to send after the tmux prefix
---@return table
local function tmux_ctrl(key, tmux_key)
  return {
    key = key,
    mods = 'CMD|CTRL',
    action = act.Multiple({
      act.SendKey(TMUX_PREFIX),
      act.SendKey({ key = tmux_key }),
    }),
  }
end

--- Send CMD+key (or CMD+SHIFT/CMD+CTRL) as tmux prefix + table_key + action_key.
--- Used for tmux key-table bindings (two-key sequences after prefix).
---@param key string  WezTerm key to bind
---@param mods string  WezTerm modifier(s) (e.g. 'CMD', 'CMD|SHIFT', 'CMD|CTRL')
---@param table_key string  Key that activates the tmux key table
---@param action_key string  Key within the table
---@return table
local function tmux_table(key, mods, table_key, action_key)
  return {
    key = key,
    mods = mods,
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.Multiple({
        act.SendKey(TMUX_PREFIX),
        act.SendKey({ key = table_key }),
      }), pane)
      wezterm.sleep_ms(10)
      window:perform_action(act.SendKey({ key = action_key }), pane)
    end),
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
  -- When tmux enables mouse reporting (`set -g mouse on`), WezTerm forwards
  -- all mouse events to the application. This setting tells WezTerm to keep
  -- CMD-modified mouse events local so CMD+Click URL opening works in tmux.
  config.bypass_mouse_reporting_modifiers = 'CMD'

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
    tmux(';', ';'),                -- CMD+;       = last pane
    {                              -- CMD+O       = rotate panes
      key = 'o', mods = 'CMD',
      action = act.Multiple({
        act.SendKey(TMUX_PREFIX),
        act.SendKey({ mods = 'CTRL', key = 'o' }),
      }),
    },
    tmux('e', 'E'),                -- CMD+E       = equalize panes
    tmux_shift('B', '!'),          -- CMD+Shift+B = break pane to window
    tmux_table('c', 'CMD|SHIFT', 'O', 'c'), -- CMD+Shift+C = Claude Code split

    -- Pane resize (sends prefix + M-Arrow)
    {                              -- CMD+Shift+Left  = resize left 5
      key = 'LeftArrow', mods = 'CMD|SHIFT',
      action = act.Multiple({
        act.SendKey(TMUX_PREFIX),
        act.SendKey({ mods = 'ALT', key = 'LeftArrow' }),
      }),
    },
    {                              -- CMD+Shift+Right = resize right 5
      key = 'RightArrow', mods = 'CMD|SHIFT',
      action = act.Multiple({
        act.SendKey(TMUX_PREFIX),
        act.SendKey({ mods = 'ALT', key = 'RightArrow' }),
      }),
    },
    {                              -- CMD+Shift+Up    = resize up 5
      key = 'UpArrow', mods = 'CMD|SHIFT',
      action = act.Multiple({
        act.SendKey(TMUX_PREFIX),
        act.SendKey({ mods = 'ALT', key = 'UpArrow' }),
      }),
    },
    {                              -- CMD+Shift+Down  = resize down 5
      key = 'DownArrow', mods = 'CMD|SHIFT',
      action = act.Multiple({
        act.SendKey(TMUX_PREFIX),
        act.SendKey({ mods = 'ALT', key = 'DownArrow' }),
      }),
    },

    -- Window management
    tmux('t', 'c'),                -- CMD+T       = new window
    tmux_shift('W', '&'),          -- CMD+Shift+W = close window
    tmux('h', 'p'),                -- CMD+H       = previous window
    tmux('l', 'n'),                -- CMD+L       = next window
    tmux_shift('H', '<'),          -- CMD+Shift+H = swap window left
    tmux_shift('L', '>'),          -- CMD+Shift+L = swap window right
    tmux_shift('E', ','),          -- CMD+Shift+E = rename window
    tmux('0', 'a'),                -- CMD+0       = last window
    tmux('1', '1'),                -- CMD+1       = window 1
    tmux('2', '2'),                -- CMD+2       = window 2
    tmux('3', '3'),                -- CMD+3       = window 3
    tmux('4', '4'),                -- CMD+4       = window 4
    tmux('5', '5'),                -- CMD+5       = window 5
    tmux('6', '6'),                -- CMD+6       = window 6
    tmux('7', '7'),                -- CMD+7       = window 7
    tmux('8', '8'),                -- CMD+8       = window 8
    tmux('9', '9'),                -- CMD+9       = window 9

    -- Session management — N (Navigate) key table
    tmux_table('k', 'CMD|SHIFT', 'N', 's'),   -- CMD+Shift+K = sesh picker
    tmux_table('k', 'CMD', 'N', 'w'),         -- CMD+K       = session/window tree
    tmux_table('j', 'CMD', 'N', 'j'),         -- CMD+J       = last session
    tmux_table('n', 'CMD', 'N', 'n'),         -- CMD+N       = new session
    tmux_table('h', 'CMD|CTRL', 'N', 'h'),    -- CMD+Ctrl+H  = previous session
    tmux_table('l', 'CMD|CTRL', 'N', 'l'),    -- CMD+Ctrl+L  = next session
    tmux_table('e', 'CMD|CTRL', 'N', 'e'),    -- CMD+Ctrl+E  = rename session
    tmux_table('w', 'CMD|CTRL', 'N', 'k'),    -- CMD+Ctrl+W  = kill session

    -- Copy mode
    tmux('[', '['),                -- CMD+[       = enter copy mode

    -- Tool launchers — O (Open) key table
    tmux_table('g', 'CMD', 'O', 'g'),         -- CMD+G       = lazygit popup
    tmux_table('y', 'CMD', 'O', 'y'),         -- CMD+Y       = yazi
    tmux_table('i', 'CMD', 'O', 'i'),         -- CMD+I       = items (taskwarrior-tui)
    tmux_table('b', 'CMD', 'O', 'b'),         -- CMD+B       = btm
    tmux_table('u', 'CMD', 'O', 'u'),         -- CMD+U       = fzf-url picker
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
