-- Adapted from the amazing kickstart.nvim

-- Set <space> as the leader key
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require "shamindras.core.options" -- general options
require "shamindras.core.autocmds" -- autocommands
require "shamindras.core.keymaps" -- custom keymaps
require "shamindras.core.lazy-bootstrap" -- lazy package manager

-- [[ Configure and install plugins ]]
require('lazy').setup({

  -- colorscheme
  require 'shamindras.plugins.tokyonight',

  -- fuzzy finder
  require 'shamindras.plugins.telescope'

}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '?',
      config = '??',
      event = '??',
      ft = '??',
      init = '?',
      keys = '??',
      plugin = '??',
      runtime = '??',
      require = '??',
      source = '??',
      start = '??',
      task = '??',
      lazy = '?? ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
