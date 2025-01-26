-- Adapted from the amazing kickstart.nvim

-- Set <space> as the leader key
-- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'shamindras.core.options'        -- general options
require 'shamindras.core.autocmds'       -- autocommands
require 'shamindras.core.keymaps'        -- custom keymaps
require 'shamindras.core.lazy-bootstrap' -- lazy package manager

-- [[ Configure and install plugins ]]
require('lazy').setup({

  -- colorscheme
  require 'shamindras.plugins.tokyonight',

  -- which.key
  require 'shamindras.plugins.which-key',

  -- fuzzy finder
  require 'shamindras.plugins.telescope',

  -- lsp
  require 'shamindras.plugins.lspconfig',

  -- cmp
  require 'shamindras.plugins.cmp',

  -- treesitter
  require 'shamindras.plugins.treesitter',

  -- todo comments
  require 'shamindras.plugins.todo-comments',

  -- formatters and linters
  require 'shamindras.plugins.none-ls',

  -- mini.nvim
  require 'shamindras.plugins.mini',

  -- comment
  require 'shamindras.plugins.comment',

  -- smart-splits
  require 'shamindras.plugins.smart-splits',

  -- tabout
  -- require 'shamindras.plugins.tabout',
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

-- vim: ts=2 sts=2 sw=2 et
