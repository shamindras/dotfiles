-- Appearance

-- {{{ Boilerplate & Helpers

local M = {}
local wezterm = require('wezterm')

---@param arg { light: any, dark: any }
local function depending_on_appearance(arg)
  local appearance = wezterm.gui.get_appearance()
  if appearance:find('Dark') then
    return arg.dark
  else
    return arg.light
  end
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Configuration Registry

-- stylua: ignore start

-- Only change these `active` values to toggle options
local active = {
  font    = 'RobotoMono',
  theme   = 'nightfox',
  size    = 20,
  opacity = 0.90,
  blur    = 4,
  padding = { left = 0, right = 0, top = 0, bottom = 0 },
}

-- Registry of available fonts
local font_library = {
  Cascadia    = 'Cascadia Code NF',
  CommitMono  = 'CommitMono Nerd Font',
  Hack        = 'Hack Nerd Font Mono',
  Iosevka     = 'Iosevka Nerd Font Mono',
  JetBrains   = 'JetBrainsMono Nerd Font',
  Maple       = 'Maple Mono',
  MonaspiceAr = 'MonaspiceAr Nerd Font',
  MonaspiceNe = 'MonaspiceNe Nerd Font',
  RobotoMono  = 'RobotoMono Nerd Font',
  Victor      = 'Victor Mono',
}

-- Registry of available themes
local theme_library = {
  dayfox           = { light = 'dayfox', dark = 'dayfox' },
  nightfox         = { light = 'nightfox', dark = 'nightfox' },
  nightowl         = { light = 'Night Owl (Gogh)', dark = 'Night Owl (Gogh)' },
  catppuccin_mocha = { light = 'Catppuccin Mocha', dark = 'Catppuccin Mocha' },
}

-- stylua: ignore end

-- ------------------------------------------------------------------------- }}}

-- {{{ Main Setup Logic

function M.setup(config)
  -- Font Configuration
  local selected_font = font_library[active.font] or font_library['JetBrains']
  config.font = wezterm.font({ family = selected_font, weight = 'Regular' })
  config.font_size = active.size

  -- Color Scheme and Window Appearance
  local theme = theme_library[active.theme] or theme_library['nightfox']
  config.color_scheme = depending_on_appearance(theme)

  config.window_background_opacity = active.opacity
  config.macos_window_background_blur = active.blur
  config.window_decorations = 'RESIZE'
  config.window_close_confirmation = 'NeverPrompt'
  config.native_macos_fullscreen_mode = true

  -- Tab Bar and Layout
  config.enable_tab_bar = false
  config.window_padding = active.padding

  return config
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Module Export

return M

-- ------------------------------------------------------------------------- }}}
