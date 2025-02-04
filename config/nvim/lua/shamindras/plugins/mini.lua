return {

  -- Text editing plugins
  {
    'echasnovski/mini.ai',
    version = '*',
    event = 'VeryLazy', -- Load after startup
    config = function()
      require('mini.ai').setup()
    end,
  },
  {
    'echasnovski/mini.operators',
    version = '*',
    event = 'VeryLazy', -- Load after startup
    config = function()
      require('mini.operators').setup()
    end,
  },
  {
    'echasnovski/mini.surround',
    version = '*',
    event = { 'BufReadPost', 'BufNewFile' }, -- Load when buffer is read or created
    config = function()
      require('mini.surround').setup()
    end,
  },
  {
    'echasnovski/mini.move',
    version = '*',
    event = { 'BufReadPost', 'BufNewFile' }, -- Load when buffer is read or created
    config = function()
      require('mini.move').setup {
        mappings = {
          left = 'H',
          right = 'L',
          down = 'J',
          up = 'K',
        },
      }
    end,
  },
  {
    'echasnovski/mini.pairs',
    version = '*',
    event = 'InsertEnter', -- Load when entering insert mode
    config = function()
      require('mini.pairs').setup()
    end,
  },
  -- General workflow plugins

  -- Appearance plugins
  {
    'echasnovski/mini.statusline',
    version = '*',
    event = 'VimEnter', -- Load when Vim starts
    config = function()
      -- Simple and easy statusline
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- Configure cursor location section to show LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
