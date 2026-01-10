-- Adapted from the amazing kickstart.nvim

-- {{{ Set leader keys -------------------------------------------------------------------------------

-- Set <space> as the leader key
-- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- }}}

-- {{{ Load custom settings --------------------------------------------------------------------------

require('shamindras.core.options') -- general options
require('shamindras.core.autocmds') -- autocommands
require('shamindras.core.keymaps') -- custom keymaps
require('shamindras.core.lazy-bootstrap') -- lazy package manager

-- }}}

-- {{{ Configure and install plugins ------------------------------------------------------------------------

require('lazy').setup({

  -- colorscheme
  require('shamindras.plugins.colorscheme'),

  -- which.key
  -- require('shamindras.plugins.which-key'),

  -- todo comments
  require('shamindras.plugins.todo-comments'),

  -- fuzzy finder
  require('shamindras.plugins.snacks'),

  -- lsp
  require('shamindras.plugins.lspconfig'),

  -- cmp
  require('shamindras.plugins.cmp'),

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

  -- comment
  require('shamindras.plugins.comment'),

  -- noice
  require('shamindras.plugins.noice'),

  -- smart-splits
  require('shamindras.plugins.smart-splits'),

  -- backout
  require('shamindras.plugins.backout'),

  -- zk (zettelkasten)
  require('shamindras.plugins.zk'),
}, {
  defaults = { lazy = false },
  install = { colorscheme = { 'tokyonight', 'darkplus', 'default' } },
  checker = { enabled = true, notify = false },
  performance = {
    cache = {
      enabled = true,
    },
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
  debug = false,
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- }}}

-- vim: ts=2 sts=2 sw=2 et
