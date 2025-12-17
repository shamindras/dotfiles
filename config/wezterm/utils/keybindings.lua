-- modules/keybindings.lua
local M = {}
local wezterm = require('wezterm')
local act = wezterm.action

-- Helper functions for pane navigation
local function is_vim(pane)
  return pane:get_user_vars().IS_NVIM == 'true'
end

local direction_keys = {
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'META' or 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        win:perform_action({
          SendKey = {
            key = key,
            mods = resize_or_move == 'resize' and 'META' or 'CTRL',
          },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

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
    split_nav('move', 'h'),
    split_nav('move', 'j'),
    split_nav('move', 'k'),
    split_nav('move', 'l'),
    -- disable alt-Enter for maximizing screen
    {
      key = 'Enter',
      mods = 'ALT',
      action = wezterm.action.DisableDefaultAssignment,
    },
    -- Tab navigation
    {
      key = 'p',
      mods = 'CMD',
      action = wezterm.action.ShowTabNavigator,
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
      action = wezterm.action.SplitHorizontal({
        domain = 'CurrentPaneDomain',
      }),
    },
    {
      key = '-',
      mods = 'CMD|SHIFT',
      action = wezterm.action.SplitVertical({
        domain = 'CurrentPaneDomain',
      }),
    },

    -- Tab management
    {
      key = 'E',
      mods = 'CMD|SHIFT',
      action = wezterm.action.PromptInputLine({
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
      action = wezterm.action.CloseCurrentPane({ confirm = false }),
    },
    {
      key = 'w',
      mods = 'CMD|SHIFT',
      action = wezterm.action.CloseCurrentTab({ confirm = true }),
    },

    -- Window management
    {
      key = 'm',
      mods = 'CMD',
      action = wezterm.action.TogglePaneZoomState,
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
      action = wezterm.action.ActivateTabRelative(-1),
    },
    {
      key = '}',
      mods = 'CMD|SHIFT',
      action = wezterm.action.ActivateTabRelative(1),
    },
  }

  return config
end

return M
