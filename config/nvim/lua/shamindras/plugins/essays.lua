-- essays.lua — keymaps for util/essays.lua (shamindras.com posts)
--
-- Virtual spec: nothing to install, but the pickers need snacks.nvim, so
-- the keys live here per the colocation rule.

return {
  'essays',
  virtual = true,
  dependencies = { 'folke/snacks.nvim' },
  keys = {
    {
      '<leader>en',
      function()
        require('shamindras.util.essays').new()
      end,
      desc = '[e]ssay [n]ew from template',
    },
    {
      '<leader>eo',
      function()
        require('shamindras.util.essays').pick_post()
      end,
      desc = '[e]ssay [o]pen post',
    },
    {
      '<leader>ep',
      function()
        require('shamindras.util.essays').preview()
      end,
      desc = '[e]ssay [p]review in browser',
    },
    {
      '<leader>ec',
      function()
        require('shamindras.util.essays').check()
      end,
      desc = '[e]ssay [c]heck prose',
    },
  },
}
