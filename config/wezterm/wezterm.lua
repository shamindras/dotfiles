-- Adapted from: https://github.com/alexpls/dotfiles/blob/master/wezterm/.config/wezterm/wezterm.lua
-- and: https://github.com/diego-vicente/dotfiles/blob/master/wezterm/wezterm.lua

-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

local set_environment_variables = {
  PATH =
  -- wezterm.home_dir ..
  -- '/.local/share/cargo/bin:' ..
      '/usr/local/bin:'
      .. os.getenv 'PATH',
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
  light = 'Catppuccin Mocha',
  dark = 'tokyonight_night',
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
    local name = string.gsub(str, "(.*/)(.*)", "%2")
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
      win:perform_action(
        wezterm.action.ActivatePaneDirection(direction),
        pane
      )
    end
  end
end

-- keybindings
config.keys = {
  -- Show tab navigator
  {
    key = 'p',
    mods = 'CMD',
    action = wezterm.action.ShowTabNavigator
  },
  -- Show launcher menu
  {
    key = 'P',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ShowLauncher
  },

  -- Vertical pipe (|) -> horizontal split
  {
    key = '\\',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitHorizontal {
      domain = 'CurrentPaneDomain'
    },
  },
  -- Underscore (_) -> vertical split
  {
    key = '-',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical {
      domain = 'CurrentPaneDomain'
    },
  },

  -- Rename current tab
  {
    key = 'E',
    mods = 'CMD|SHIFT',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(
        function(window, _, line)
          if line then
            window:active_tab():set_title(line)
          end
        end
      ),
    },
  },

  -- Move to a pane (prompt to which one)
  {
    mods = "CMD",
    key = "m",
    action = wezterm.action.PaneSelect
  },

  -- Use CMD + [h|j|k|l] to move between panes
  {
    key = "h",
    mods = "CMD",
    action = wezterm.action_callback(bind_movement('h', 'Left'))
  },

  {
    key = "j",
    mods = "CMD",
    action = wezterm.action_callback(bind_movement('j', 'Down'))
  },

  {
    key = "k",
    mods = "CMD",
    action = wezterm.action_callback(bind_movement('k', 'Up'))
  },

  {
    key = "l",
    mods = "CMD",
    action = wezterm.action_callback(bind_movement('l', 'Right'))
  },

  -- Move to another pane (next or previous)
  {
    key = "[",
    mods = "CMD",
    action = wezterm.action.ActivatePaneDirection('Prev')
  },

  {
    key = "]",
    mods = "CMD",
    action = wezterm.action.ActivatePaneDirection('Next')
  },

  -- Move to another tab (next or previous)
  {
    key = "{",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivateTabRelative(-1)
  },

  {
    key = "}",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivateTabRelative(1)
  },

  -- Use CMD+Shift+S t swap the active pane and another one
  {
    key = "s",
    mods = "CMD|SHIFT",
    action = wezterm.action {
      PaneSelect = { mode = "SwapWithActiveKeepFocus" }
    }
  },

  -- Use CMD+w to close the pane, CMD+SHIFT+w to close the tab
  {
    key = "w",
    mods = "CMD",
    action = wezterm.action.CloseCurrentPane { confirm = false }
  },

  {
    key = "w",
    mods = "CMD|SHIFT",
    action = wezterm.action.CloseCurrentTab { confirm = true }
  },

  -- Use CMD+z to enter zoom state
  {
    key = 'z',
    mods = 'CMD',
    action = wezterm.action.TogglePaneZoomState,
  },

  -- start a new tab
  {
    key = 't',
    mods = 'CMD',
    action = act.SpawnTab 'CurrentPaneDomain',
  },

  -- start `lazygit` in a new tab
  {
    key = 'g',
    mods = 'CMD',
    action = act.SpawnCommandInNewTab {
      args = { 'lazygit' },
    },
  },
}

-- and finally, return the configuration to wezterm
return config
