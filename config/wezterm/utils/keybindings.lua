-- {{{ Boilerplate & Helpers

local M = {}
local wezterm = require('wezterm')
local act = wezterm.action

---@param pane table
---@return boolean
local function is_vim(pane)
  return pane:get_user_vars().IS_NVIM == 'true'
end

local direction_keys = {
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

-- ------------------------------------------------------------------------- }}}

-- {{{ Vim-Aware Navigation

---@param key string
---@return table
local function nav_key(key)
  return {
    key = key,
    mods = 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        win:perform_action({
          SendKey = { key = key, mods = 'CTRL' },
        }, pane)
      else
        win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
      end
    end),
  }
end

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

  -- Keyboard shortcuts
  config.keys = {
    -- Pane navigation
    nav_key('h'),
    nav_key('j'),
    nav_key('k'),
    nav_key('l'),
    -- disable alt-Enter for maximizing screen
    {
      key = 'Enter',
      mods = 'ALT',
      action = act.DisableDefaultAssignment,
    },
    -- Tab navigation
    {
      key = 'p',
      mods = 'CMD',
      action = act.ShowTabNavigator,
    },
    {
      key = 'g',
      mods = 'CMD',
      action = act.SpawnCommandInNewTab({
        args = { 'lazygit' },
      }),
    },

    -- Split management
    {
      key = '\\',
      mods = 'CMD|SHIFT',
      action = act.SplitHorizontal({
        domain = 'CurrentPaneDomain',
      }),
    },
    {
      key = '-',
      mods = 'CMD|SHIFT',
      action = act.SplitVertical({
        domain = 'CurrentPaneDomain',
      }),
    },

    -- Tab management
    {
      key = 'E',
      mods = 'CMD|SHIFT',
      action = act.PromptInputLine({
        description = 'Enter new name for tab',
        action = wezterm.action_callback(function(window, _, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      }),
    },
    {
      key = 't',
      mods = 'CMD',
      action = act.SpawnTab('CurrentPaneDomain'),
    },
    {
      key = 'w',
      mods = 'CMD',
      action = act.CloseCurrentPane({ confirm = false }),
    },
    {
      key = 'w',
      mods = 'CMD|SHIFT',
      action = act.CloseCurrentTab({ confirm = true }),
    },

    -- Window management
    {
      key = 'm',
      mods = 'CMD',
      action = act.TogglePaneZoomState,
    },
    {
      key = 'k',
      mods = 'CMD',
      action = act.Multiple({
        act.ClearScrollback('ScrollbackAndViewport'),
        act.SendKey({ key = 'L', mods = 'CTRL' }),
      }),
    },

    -- Tab switching
    {
      key = '{',
      mods = 'CMD|SHIFT',
      action = act.ActivateTabRelative(-1),
    },
    {
      key = '}',
      mods = 'CMD|SHIFT',
      action = act.ActivateTabRelative(1),
    },
  }

  return config
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Module Export

return M

-- ------------------------------------------------------------------------- }}}
