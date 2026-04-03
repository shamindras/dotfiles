-- {{{ Navigation Keymaps

return {
  'mrjones2014/smart-splits.nvim',
  keys = {
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

    -- }}}

    -- {{{ Resize Keymaps

    {
      '<leader>wh',
      function()
        require('smart-splits').resize_left()
      end,
      mode = 'n',
      desc = '[w]indow resize left [h]',
    },
    {
      '<leader>wj',
      function()
        require('smart-splits').resize_down()
      end,
      mode = 'n',
      desc = '[w]indow resize down [j]',
    },
    {
      '<leader>wk',
      function()
        require('smart-splits').resize_up()
      end,
      mode = 'n',
      desc = '[w]indow resize up [k]',
    },
    {
      '<leader>wl',
      function()
        require('smart-splits').resize_right()
      end,
      mode = 'n',
      desc = '[w]indow resize right [l]',
    },

    -- }}}

    -- {{{ Swap Keymaps

    {
      '<leader>wH',
      function()
        require('smart-splits').swap_buf_left()
      end,
      mode = 'n',
      desc = '[w]indow swap left [H]',
    },
    {
      '<leader>wJ',
      function()
        require('smart-splits').swap_buf_down()
      end,
      mode = 'n',
      desc = '[w]indow swap down [J]',
    },
    {
      '<leader>wK',
      function()
        require('smart-splits').swap_buf_up()
      end,
      mode = 'n',
      desc = '[w]indow swap up [K]',
    },
    {
      '<leader>wL',
      function()
        require('smart-splits').swap_buf_right()
      end,
      mode = 'n',
      desc = '[w]indow swap right [L]',
    },
  },

  -- }}}

  opts = {},
}
