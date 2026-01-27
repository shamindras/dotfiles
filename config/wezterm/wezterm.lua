-- wezterm.lua (main configuration file)
local wezterm = require('wezterm')

-- Import utils
local appearance = require('utils.appearance')
local keybindings = require('utils.keybindings')
local core = require('utils.core')

-- Initialize configuration
local config = wezterm.config_builder()

-- Apply module configurations
config = appearance.setup(config)
config = keybindings.setup(config)
config = core.setup(config)

return config
