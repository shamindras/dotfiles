-- Adapted from: https://github.com/alexpls/dotfiles/blob/master/wezterm/.config/wezterm/wezterm.lua
-- and: https://github.com/diego-vicente/dotfiles/blob/master/wezterm/wezterm.lua

require 'utils.tab_title'

-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

local set_environment_variables = {
  PATH = '/usr/local/bin:' .. os.getenv 'PATH',
}

config.set_environment_variables = set_environment_variables

config.font =
  wezterm.font { family = 'JetBrainsMono Nerd Font', weight = 'Regular' }
config.font_size = 20

---Return the suitable argument depending on the appearance
---@param arg { light: any, dark: any } light and dark alternatives
---@return any
local function depending_on_appearance(arg)
  local appearance = wezterm.gui.get_appearance()
  if appearance:find 'Dark' then
    return arg.dark
  else
    return arg.light
  end
end

config.color_scheme = depending_on_appearance {
  -- light = 'tokyonight_night',
  -- dark = 'tokyonight_night',
  light = 'Night Owl (Gogh)',
  dark = 'Night Owl (Gogh)',
}
config.enable_tab_bar = true

config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.90
config.macos_window_background_blur = 4

config.default_prog = { '/bin/zsh', '-l' }
config.launch_menu = {
  {
    label = 'zsh',
    args = { '/bin/zsh', '-l' },
  },
}

-- never prompt when closing Wezterm
config.window_close_confirmation = 'NeverPrompt'

-- make fullscreen mode default on macOS
config.native_macos_fullscreen_mode = true

-- set the pane focus by hovering over with the mouse.
config.pane_focus_follows_mouse = true

-- Mouse events
config.mouse_bindings = {
  -- Open URLs with CMD+Click
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = act.OpenLinkAtMouseCursor,
  },
}

--- Bind a movement key to a direction
---
--- If the current pane is running nvim, send the key to it using CTRL
--- as the modifier instead. If not, move the next pane in the given
--- direction.
--- @param key string the key to send
--- @param direction string the direction to move the pane
local function bind_movement(key, direction)
  local function basename(str)
    local name = string.gsub(str, '(.*/)(.*)', '%2')
    return name
  end

  return function(win, pane)
    local name = basename(pane:get_foreground_process_name())
    win:toast_notification('wezterm', name, nil, 4000)
    if name == 'nvim' then
      win:perform_action(
        wezterm.action.SendKey { key = key, mods = 'CTRL' },
        pane
      )
    else
      win:perform_action(wezterm.action.ActivatePaneDirection(direction), pane)
    end
  end
end

-- smart-splits integration
-- source: https://dev.to/lovelindhoni/make-wezterm-mimic-tmux-5893
-- TODO: modularize this code
-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
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
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = {
            key = key,
            mods = resize_or_move == 'resize' and 'META' or 'CTRL',
          },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action(
            { AdjustPaneSize = { direction_keys[key], 3 } },
            pane
          )
        else
          win:perform_action(
            { ActivatePaneDirection = direction_keys[key] },
            pane
          )
        end
      end
    end),
  }
end

-- keybindings
config.keys = {

  -- move between split panes
  -- smart-splits
  split_nav('move', 'h'),
  split_nav('move', 'j'),
  split_nav('move', 'k'),
  split_nav('move', 'l'),

  -- resize panes
  -- TODO: this is not currently working with neovim
  -- split_nav('resize', 'h'),
  -- split_nav('resize', 'j'),
  -- split_nav('resize', 'k'),
  -- split_nav('resize', 'l'),
  {
    key = 'p',
    mods = 'CMD',
    action = wezterm.action.ShowTabNavigator,
  },
  {
    key = 'g',
    mods = 'CMD',
    action = act.SpawnCommandInNewTab {
      args = { 'lazygit' },
    },
  },
  -- Show launcher menu
  {
    key = 'P',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ShowLauncher,
  },

  -- [v]ertical split wezterm window
  {
    -- key = 'v',
    key = '\\', -- Vertical pipe (|) -> vertical split
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitHorizontal {
      domain = 'CurrentPaneDomain',
    },
  },
  -- [h]orizontal split wezterm window
  {
    -- key = 'h',
    key = '-', -- Underscore (_) -> horizontal split
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical {
      domain = 'CurrentPaneDomain',
    },
  },

  -- Rename current tab
  {
    key = 'E',
    mods = 'CMD|SHIFT',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- Clears the scrollback and viewport, and then sends CTRL-L to ask the
  -- shell to redraw its prompt
  {
    key = 'k',
    mods = 'CMD',
    action = act.Multiple {
      act.ClearScrollback 'ScrollbackAndViewport',
      act.SendKey { key = 'L', mods = 'CTRL' },
    },
  },

  -- Use CTRL + [h|j|k|l] to move between panes
  {
    key = 'h',
    mods = 'CTRL',
    action = wezterm.action_callback(bind_movement('h', 'Left')),
  },

  {
    key = 'j',
    mods = 'CTRL',
    action = wezterm.action_callback(bind_movement('j', 'Down')),
  },

  {
    key = 'k',
    mods = 'CTRL',
    action = wezterm.action_callback(bind_movement('k', 'Up')),
  },

  {
    key = 'l',
    mods = 'CTRL',
    action = wezterm.action_callback(bind_movement('l', 'Right')),
  },

  -- Move to another pane (next or previous)
  {
    key = '[',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection 'Prev',
  },

  {
    key = ']',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection 'Next',
  },

  -- Move to another tab (next or previous)
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

  -- Use CMD+Shift+S t swap the active pane and another one
  {
    key = 's',
    mods = 'CMD|SHIFT',
    action = wezterm.action {
      PaneSelect = { mode = 'SwapWithActiveKeepFocus' },
    },
  },

  -- Use CMD+w to close the pane, CMD+SHIFT+w to close the tab
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },

  {
    key = 'w',
    mods = 'CMD|SHIFT',
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },

  -- Use CMD+m to enter zoom state
  {
    key = 'm',
    mods = 'CMD',
    action = wezterm.action.TogglePaneZoomState,
  },

  -- start a new tab
  {
    key = 't',
    mods = 'CMD',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
}

-- and finally, return the configuration to wezterm
return config
