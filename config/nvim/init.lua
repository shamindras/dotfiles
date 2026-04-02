-- Adapted from the amazing kickstart.nvim

-- {{{ Leader Keys

-- Set <space> as the leader key
-- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- }}}

-- {{{ Core Modules

require('shamindras.core.options') -- general options
require('shamindras.core.autocmds') -- autocommands
require('shamindras.core.keymaps') -- custom keymaps
require('shamindras.core.lazy-bootstrap') -- lazy package manager

-- }}}

-- {{{ Plugin Setup

require('lazy').setup({

  -- colorscheme
  require('shamindras.plugins.colorscheme'),

  -- fuzzy finder
  require('shamindras.plugins.snacks'),

  -- lsp
  require('shamindras.plugins.lspconfig'),

  -- blink
  require('shamindras.plugins.blink'),

  -- treesitter
  require('shamindras.plugins.treesitter'),

  -- linters
  require('shamindras.plugins.nvim-lint'),

  -- formatters
  require('shamindras.plugins.conform'),

  -- flash (jump)
  require('shamindras.plugins.flash'),

  -- mini.nvim
  require('shamindras.plugins.mini'),

  -- noice
  require('shamindras.plugins.noice'),

  -- smart-splits
  require('shamindras.plugins.smart-splits'),

  -- zk (zettelkasten)
  require('shamindras.plugins.zk'),

  -- markdown
  require('shamindras.plugins.markdown'),
  require('shamindras.plugins.render-markdown'),
}, {
  defaults = { lazy = true },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        '2html_plugin',
        'bugreport',
        'compiler',
        'ftplugin',
        'getscript',
        'getscriptPlugin',
        'gzip',
        'logipat',
        'matchit',
        'netrw',
        'netrwFileHandlers',
        'netrwPlugin',
        'netrwSettings',
        'optwin',
        'rplugin',
        'rrhelper',
        'spellfile_plugin',
        'synmenu',
        'syntax',
        'tar',
        'tarPlugin',
        'tohtml',
        'tutor',
        'vimball',
        'vimballPlugin',
        'zip',
        'zipPlugin',
      },
    },
  },
  ui = {
    icons = {}, -- uses default lazy.nvim Nerd Font icons
  },
})

-- }}}
