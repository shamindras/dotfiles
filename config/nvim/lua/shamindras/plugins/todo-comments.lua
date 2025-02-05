-- Highlight todo, notes, etc in comments
return {
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = { 'BufReadPost', 'BufNewFile' },
    opts = { signs = false },
  },
}

-- vim: ts=2 sts=2 sw=2 et
