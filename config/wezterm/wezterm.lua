-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

local set_environment_variables = {
  PATH = wezterm.home_dir
    .. '/.cargo/bin:'
    .. '/usr/local/bin:'
    .. os.getenv 'PATH',
}

config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 14

config.color_scheme = 'tokyonight_night'
config.enable_tab_bar = true

config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.95
config.macos_window_background_blur = 10

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
-- keybindings
config.keys = {
  -- Underscore (_) -> vertical split
  {
    key = '-',
    mods = 'CMD|SHIFT',
    action = act.SplitVertical {
      domain = 'CurrentPaneDomain',
    },
  },
  {
    key = 't',
    mods = 'CMD',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
  -- CMD-g starts `lazygit` in a new tab
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
