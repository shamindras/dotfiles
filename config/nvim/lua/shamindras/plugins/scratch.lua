-- scratch.lua — keymaps for util/scratch.lua (markdown scratch notes)
--
-- Virtual spec: nothing to install, but the picker and promote paths need
-- snacks.nvim and zk-nvim, so the keys live here per the colocation rule.

return {
  'scratch',
  virtual = true,
  dependencies = { 'folke/snacks.nvim', 'zk-org/zk-nvim' },
  keys = {
    {
      '<leader>nn',
      function()
        require('shamindras.util.scratch').prompt_new()
      end,
      desc = '[n]ote [n]ew scratch',
    },
    {
      '<leader>nf',
      function()
        require('shamindras.util.scratch').pick()
      end,
      desc = '[n]ote [f]ind scratch',
    },
    {
      '<leader>ng',
      function()
        require('shamindras.util.scratch').grep()
      end,
      desc = '[n]ote [g]rep scratch',
    },
    {
      '<leader>nl',
      function()
        require('shamindras.util.scratch').last()
      end,
      desc = '[n]ote [l]ast scratch',
    },
    {
      '<leader>nr',
      function()
        require('shamindras.util.scratch').rename_from_heading()
      end,
      desc = '[n]ote [r]ename from heading',
    },
    {
      '<leader>np',
      function()
        require('shamindras.util.scratch').promote_current()
      end,
      desc = '[n]ote [p]romote to zk idea',
    },
    {
      '<leader>nd',
      function()
        require('shamindras.util.scratch').delete_current()
      end,
      desc = '[n]ote [d]elete scratch',
    },
  },
}
