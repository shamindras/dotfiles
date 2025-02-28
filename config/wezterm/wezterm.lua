-- wezterm.lua (main configuration file)
local wezterm = require('wezterm')

-- Import utils
local appearance = require('utils.appearance')
local keybindings = require('utils.keybindings')
local core = require('utils.core')
local tab_title = require('utils.tab_title')

-- Initialize configuration
local config = wezterm.config_builder()

-- Set up tab title formatting
tab_title.setup()

-- Apply module configurations
config = appearance.setup(config)
config = keybindings.setup(config)
config = core.setup(config)

return config
