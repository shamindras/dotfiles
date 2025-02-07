return {
  {
    'abecodes/tabout.nvim',
    event = 'InsertEnter', -- Load when entering insert mode
    config = function()
      require('tabout').setup {
        tabkey = '<Tab>',
        backwards_tabkey = '<S-Tab>',
        act_as_tab = true,
        act_as_shift_tab = false,
        default_tab = '<C-t>',
        default_shift_tab = '<C-d>',
        enable_backwards = true,
        completion = false,
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = '`', close = '`' },
          { open = '(', close = ')' },
          { open = '[', close = ']' },
          { open = '{', close = '}' },
        },
        ignore_beginning = true,
        exclude = {},
      }
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'L3MON4D3/LuaSnip',
      'hrsh7th/nvim-cmp',
    },
    -- Remove opt = true as it's redundant with lazy loading
    -- Remove priority since it's not needed here
  },
  {
    'L3MON4D3/LuaSnip',
    keys = function()
      return {}
    end,
  },
}

