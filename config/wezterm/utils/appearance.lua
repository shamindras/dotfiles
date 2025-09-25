-- modules/appearance.lua
local M = {}
local wezterm = require('wezterm')

---Return the suitable argument depending on the appearance
---@param arg { light: any, dark: any } light and dark alternatives
---@return any
local function depending_on_appearance(arg)
  local appearance = wezterm.gui.get_appearance()
  if appearance:find('Dark') then
    return arg.dark
  else
    return arg.light
  end
end

function M.setup(config)
  -- Font configuration
  config.font =
    -- wezterm.font({ family = 'MonaspiceNe Nerd Font', weight = 'Regular' })
    -- wezterm.font({ family = 'Victor Mono', weight = 'Regular' })
    -- wezterm.font({ family = 'MonaspiceAr Nerd Font', weight = 'Regular' })
    -- wezterm.font({ family = 'Iosevka Nerd Font Mono', weight = 'Regular' })
    -- wezterm.font({ family = 'Maple Mono', weight = 'Regular' })
    -- wezterm.font({ family = 'Cascadia Code NF', weight = 'Regular' })
    -- wezterm.font({ family = 'JetBrainsMono Nerd Font', weight = 'Regular' })
    wezterm.font({ family = 'CommitMono Nerd Font', weight = 'Regular' })
  config.font_size = 20

  -- Color scheme and window appearance
  config.color_scheme = depending_on_appearance({
    -- light = 'Night Owl (Gogh)',
    -- dark = 'Night Owl (Gogh)',
    light = 'Catppuccin Mocha (Gogh)',
    dark = 'Catppuccin Mocha (Gogh)',
  })

  -- Window configuration
  config.enable_tab_bar = false
  config.window_decorations = 'RESIZE'
  config.window_background_opacity = 0.90
  config.macos_window_background_blur = 4
  config.window_close_confirmation = 'NeverPrompt'
  config.native_macos_fullscreen_mode = true

  -- Window padding
  config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  }

  return config
end

return M
