return { -- Fuzzy Finder (files, lsp, etc)
  'mrjones2014/smart-splits.nvim',
  lazy = false,
  config = function()
    require('smart-splits').setup()

    -- moving between splits
    vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
    vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
    vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
    vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
    vim.keymap.set('n', '<C-\\>', require('smart-splits').move_cursor_previous)

    -- swapping buffers between windows
    vim.keymap.set('n', '<leader>wH', require('smart-splits').swap_buf_left)
    vim.keymap.set('n', '<leader>wJ', require('smart-splits').swap_buf_down)
    vim.keymap.set('n', '<leader>wK', require('smart-splits').swap_buf_up)
    vim.keymap.set('n', '<leader>wL', require('smart-splits').swap_buf_right)
  end,
}
