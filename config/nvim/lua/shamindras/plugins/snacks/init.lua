-- ~/.config/nvim/lua/plugins/snacks/init.lua
return {
  'folke/snacks.nvim',
  event = {
    'VeryLazy', -- Load after other plugins
    'BufReadPre', -- Load before reading a file
  },
  keys = {
    -- Pre-define keymaps so lazy.nvim knows about them
    { '<leader><space>', desc = '[S]mart [F]ind Files' },
    { '<leader>,', desc = '[F]ind [B]uffers (Ivy Layout)' },
    { '<leader>/', desc = '[F]ind [G]rep' },
    { '<leader>:', desc = '[C]ommand [H]istory' },
    { '<leader>n', desc = '[N]otification [H]istory' },
    { '<leader>e', desc = '[F]ile [E]xplorer' },
    { '<leader>ff', desc = '[F]ind [F]iles' },
    { '<leader>fb', desc = '[F]ind [B]uffers (Ivy Layout)' },
    { '<leader>fc', desc = '[F]ind [C]onfig file' },
    { '<leader>fg', desc = '[F]ind [G]it [F]iles' },
    { '<leader>fp', desc = '[F]ind [P]rojects' },
    { '<leader>fr', desc = '[F]ind [R]ecent' },
    { '<leader>lg', desc = '[L]azy[G]it' },
  },
  config = function()
    local Snacks = require 'snacks'

    -- Set up Snacks with minimal configuration
    Snacks.setup {
      picker = {
        matcher = {
          sort_empty = true,
          cwd_bonus = true,
          frecency = true,
          history_bonus = true,
        },
      },
      explorer = {},
      lazygit = {
        configure = false,
        win = {
          style = 'lazygit',
          width = 0.99,
          height = 0.99,
          row = 0,
          col = 0,
          border = 'none',
        },
      },
      opts = {
        indent = {},
      },
    }

    -- Enable indent guides
    -- Snacks.indent.enable()

    -- Set up all picker-related keymaps
    require('shamindras.plugins.snacks.pickers').setup_keymaps()
  end,
}
