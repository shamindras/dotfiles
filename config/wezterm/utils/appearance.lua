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

-- Only change these `active` values to toggle options
-- Use the keys from the libraries below (e.g., 'Victor', 'catppuccin_mocha')
local active = {
  font = 'JetBrains',
  theme = 'nightfox',
}

-- Registry of available fonts
local font_library = {
  Maple = 'Maple Mono',
  Victor = 'Victor Mono',
  MonaspiceNe = 'MonaspiceNe Nerd Font',
  MonaspiceAr = 'MonaspiceAr Nerd Font',
  Iosevka = 'Iosevka Nerd Font Mono',
  Cascadia = 'Cascadia Code NF',
  JetBrains = 'JetBrainsMono Nerd Font',
  CommitMono = 'CommitMono Nerd Font',
}

-- Registry of available themes
local theme_library = {
  dayfox = { light = 'dayfox', dark = 'dayfox' },
  nightfox = { light = 'nightfox', dark = 'nightfox' },
  nightowl = { light = 'Night Owl (Gogh)', dark = 'Night Owl (Gogh)' },
  catppuccin_mocha = { light = 'Catppuccin Mocha', dark = 'Catppuccin Mocha' },
}

-- ------------------------------------------------------------------------- }}}

-- {{{ Main Setup Logic

function M.setup(config)
  -- Font Configuration
  local selected_font = font_library[active.font] or font_library['Maple']
  config.font = wezterm.font({ family = selected_font, weight = 'Regular' })
  config.font_size = 20

  -- Color Scheme and Window Appearance
  local theme = theme_library[active.theme] or theme_library['nightfox']
  config.color_scheme = depending_on_appearance(theme)
  config.window_background_opacity = 0.90
  config.macos_window_background_blur = 4
  config.window_decorations = 'RESIZE'
  config.window_close_confirmation = 'NeverPrompt'
  config.native_macos_fullscreen_mode = true

  -- Tab Bar and Layout
  config.enable_tab_bar = false
  config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

  return config
end

-- ------------------------------------------------------------------------- }}}

-- {{{ Module Export

return M

-- ------------------------------------------------------------------------- }}}
