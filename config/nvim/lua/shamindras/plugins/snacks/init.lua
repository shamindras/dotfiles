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
    { '<leader>bd', desc = '[B]uffer [D]elete' }, -- Delete Buffer
    { '<leader>bo', desc = '[B]uffer [O]ther Delete' }, -- Delete Other Buffers
    { '<leader>bD', desc = '[B]uffer and [W]indow [D]elete' }, -- Delete Buffer and Window
  },
  config = function()
    local Snacks = require('snacks')

    -- Set up Snacks with minimal configuration
    Snacks.setup({
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
    })

    -- Set up all picker-related keymaps
    require('shamindras.plugins.snacks.pickers').setup_keymaps()

    -- Custom buffer delete keymaps using vim.api
    -- TODO: import a general keymap function from a `utils` file
    vim.api.nvim_set_keymap(
      'n',
      '<leader>bd',
      [[<Cmd>lua require('snacks').bufdelete()<CR>]],
      { noremap = true, silent = true, desc = '[b]uffer [d]elete' }
    )
    vim.api.nvim_set_keymap(
      'n',
      '<leader>bo',
      [[<Cmd>lua require('snacks').bufdelete.other()<CR>]],
      { noremap = true, silent = true, desc = '[b]uffer delete [o]thers' }
    )
    vim.api.nvim_set_keymap(
      'n',
      '<leader>bD',
      '<cmd>:bd<cr>',
      { noremap = true, silent = true, desc = '[b]uffer [D]elete and window' }
    )
  end,
}
