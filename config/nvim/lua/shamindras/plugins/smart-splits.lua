return {
  'mrjones2014/smart-splits.nvim',
  lazy = true, -- Change to true since we'll load it on demand
  event = { 'VeryLazy' },
  keys = {
    -- Moving between splits
    {
      '<C-h>',
      function()
        require('smart-splits').move_cursor_left()
      end,
      mode = 'n',
      desc = 'Move to left split',
    },
    {
      '<C-j>',
      function()
        require('smart-splits').move_cursor_down()
      end,
      mode = 'n',
      desc = 'Move to bottom split',
    },
    {
      '<C-k>',
      function()
        require('smart-splits').move_cursor_up()
      end,
      mode = 'n',
      desc = 'Move to top split',
    },
    {
      '<C-l>',
      function()
        require('smart-splits').move_cursor_right()
      end,
      mode = 'n',
      desc = 'Move to right split',
    },
    {
      '<C-\\>',
      function()
        require('smart-splits').move_cursor_previous()
      end,
      mode = 'n',
      desc = 'Move to previous split',
    },

    -- Swapping buffers
    {
      '<leader>wH',
      function()
        require('smart-splits').swap_buf_left()
      end,
      mode = 'n',
      desc = 'Swap with left buffer',
    },
    {
      '<leader>wJ',
      function()
        require('smart-splits').swap_buf_down()
      end,
      mode = 'n',
      desc = 'Swap with bottom buffer',
    },
    {
      '<leader>wK',
      function()
        require('smart-splits').swap_buf_up()
      end,
      mode = 'n',
      desc = 'Swap with top buffer',
    },
    {
      '<leader>wL',
      function()
        require('smart-splits').swap_buf_right()
      end,
      mode = 'n',
      desc = 'Swap with right buffer',
    },
  },
  config = function()
    require('smart-splits').setup()
  end,
}
