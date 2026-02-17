-- {{{ Imports

local wezterm = require('wezterm')
local appearance = require('utils.appearance')
local keybindings = require('utils.keybindings')
local core = require('utils.core')

-- ------------------------------------------------------------------------- }}}

-- {{{ Configuration

---@type table
local config = wezterm.config_builder()

config = appearance.setup(config)
config = keybindings.setup(config)
config = core.setup(config)

-- ------------------------------------------------------------------------- }}}

-- {{{ Module Export

return config

-- ------------------------------------------------------------------------- }}}
