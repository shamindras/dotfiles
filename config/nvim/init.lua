-- Adapted from the amazing kickstart.nvim

-- Set <space> as the leader key
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require "shamindras.core.options" -- general options
require "shamindras.core.autocmds" -- autocommands
require "shamindras.core.keymaps" -- custom keymaps
require "shamindras.core.lazy" -- lazy package manager


