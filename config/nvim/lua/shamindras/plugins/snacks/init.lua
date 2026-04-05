-- {{{ Plugin Spec

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,

  -- }}}

  -- {{{ Snacks Configuration

  opts = {
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
  },

  -- }}}

  -- {{{ Keymaps

  keys = {
    -- Top Pickers & Explorer
    {
      '<leader><space>',
      function()
        require('shamindras.plugins.snacks.pickers').picker_with_fd(Snacks.picker.smart)
      end,
      desc = '[s]mart [f]ind files',
    },
    {
      '<leader>,',
      function()
        require('shamindras.plugins.snacks.pickers').buffers_picker()
      end,
      desc = '[b]uffers',
    },
    {
      '<leader>/',
      function()
        require('shamindras.plugins.snacks.pickers').grep_with_ripgrep()
      end,
      desc = '[g]rep',
    },
    {
      '<leader>:',
      function()
        require('shamindras.plugins.snacks.pickers').with_ivy_layout(Snacks.picker.command_history)
      end,
      desc = '[c]ommand [h]istory',
    },
    {
      '<leader>fe',
      function()
        Snacks.explorer()
      end,
      desc = '[f]ile [e]xplorer',
    },
    {
      '<leader>lg',
      function()
        Snacks.lazygit()
      end,
      desc = '[l]azy [g]it',
    },

    -- Find Pickers
    {
      '<leader>fb',
      function()
        require('shamindras.plugins.snacks.pickers').buffers_picker()
      end,
      desc = '[f]ind [b]uffers',
    },
    {
      '<leader>fc',
      function()
        require('shamindras.plugins.snacks.pickers').with_ivy_layout(
          Snacks.picker.files,
          { cwd = vim.fn.stdpath('config') }
        )
      end,
      desc = '[f]ind [c]onfig file',
    },
    {
      '<leader>ff',
      function()
        require('shamindras.plugins.snacks.pickers').picker_with_fd(Snacks.picker.files)
      end,
      desc = '[f]ind [f]iles',
    },

    -- Grep Pickers
    {
      '<leader>sg',
      function()
        require('shamindras.plugins.snacks.pickers').grep_with_ripgrep()
      end,
      desc = '[s]earch [g]rep',
    },
    {
      '<leader>sw',
      function()
        require('shamindras.plugins.snacks.pickers').with_ivy_layout(Snacks.picker.grep_word)
      end,
      mode = { 'n', 'x' },
      desc = '[s]earch selected [w]ord',
    },

    -- Search
    {
      '<leader>s"',
      function()
        require('shamindras.plugins.snacks.pickers').with_ivy_layout(Snacks.picker.registers)
      end,
      desc = '[s]earch [r]egisters',
    },
    {
      '<leader>sd',
      function()
        require('shamindras.plugins.snacks.pickers').with_ivy_layout(Snacks.picker.diagnostics)
      end,
      desc = '[s]earch [d]iagnostics',
    },
    {
      '<leader>sh',
      function()
        require('shamindras.plugins.snacks.pickers').with_ivy_layout(Snacks.picker.help)
      end,
      desc = '[s]earch [h]elp pages',
    },
    {
      '<leader>si',
      function()
        require('shamindras.plugins.snacks.pickers').with_ivy_layout(Snacks.picker.icons)
      end,
      desc = '[s]earch [i]cons',
    },
    {
      '<leader>sk',
      function()
        require('shamindras.plugins.snacks.pickers').with_ivy_layout(Snacks.picker.keymaps)
      end,
      desc = '[s]earch [k]eymaps',
    },
    {
      '<leader>sq',
      function()
        require('shamindras.plugins.snacks.pickers').with_ivy_layout(Snacks.picker.qflist)
      end,
      desc = '[s]earch [q]uickfix list',
    },
    {
      '<leader>sn',
      function()
        require('shamindras.plugins.snacks.pickers').with_ivy_layout(Snacks.picker.notifications)
      end,
      desc = '[s]earch [n]otification history',
    },
    {
      '<leader>st',
      function()
        require('shamindras.plugins.snacks.pickers').todo_comments_picker()
      end,
      desc = '[s]earch [t]odo comments (all)',
    },
    {
      '<leader>sT',
      function()
        require('shamindras.plugins.snacks.pickers').todo_comments_picker('TODO')
      end,
      desc = '[s]earch [T]ODO only',
    },
    {
      '<leader>sF',
      function()
        require('shamindras.plugins.snacks.pickers').todo_comments_picker('FIXME')
      end,
      desc = '[s]earch [F]IXME/BUG only',
    },
    {
      '<leader>sN',
      function()
        require('shamindras.plugins.snacks.pickers').todo_comments_picker('NOTE')
      end,
      desc = '[s]earch [N]OTE/INFO only',
    },
    {
      '<leader>sW',
      function()
        require('shamindras.plugins.snacks.pickers').todo_comments_picker('WARN')
      end,
      desc = '[s]earch [W]ARN only',
    },
    {
      '<leader>pc',
      function()
        require('shamindras.plugins.snacks.pickers').colorscheme_picker()
      end,
      desc = '[p]ick [c]olorscheme',
    },

    -- Buffer Delete (opens file picker if no buffers remain)
    {
      '<leader>bd',
      function()
        local is_last = #vim.fn.getbufinfo({ buflisted = 1 }) <= 1
        Snacks.bufdelete()
        if is_last then
          require('shamindras.plugins.snacks.pickers').picker_with_fd(Snacks.picker.files)
        end
      end,
      desc = '[b]uffer [d]elete',
    },
    {
      '<leader>bo',
      function()
        Snacks.bufdelete.other()
        require('shamindras.plugins.snacks.pickers').picker_with_fd(Snacks.picker.files)
      end,
      desc = '[b]uffer delete [o]thers',
    },
    { '<leader>bD', '<cmd>bd<cr>', desc = '[b]uffer [D]elete and window' },
  },

  -- }}}
}
