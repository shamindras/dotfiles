local M = {}
local Snacks = require('snacks')

-- {{{ Layout Configuration -----------------------------------------------------------------------

M.layout_config = {
  height = 0.7,
  preview_width = 0.6,
}

-- }}}

-- {{{ Custom Arguments for Pickers ---------------------------------------------------------------

-- Custom fd args for the find files picker
M.fd_args = {
  '--type',
  'f',
  '--strip-cwd-prefix',
  '--hidden',
  '--exclude',
  '.git',
  '--exclude',
  'node_modules',
  '--exclude',
  'submods',
  '--follow',
}

-- Custom ripgrep args for the grep picker (escaped glob patterns for zsh)
M.ripgrep_args = {
  '--color=never',
  '--no-heading',
  '--with-filename',
  '--line-number',
  '--column',
  '--smart-case',
  '--hidden',
  '--glob=!.git/*',
  '--glob=!node_modules/*',
  '--follow',
}

-- }}}

-- {{{ Ivy Layout Configuration -------------------------------------------------------------------

M.ivy_layout = {
  layout = {
    box = 'vertical',
    backdrop = false,
    row = -1,
    width = 0,
    height = M.layout_config.height,
    border = 'top',
    title = ' {title} {live} {flags}',
    title_pos = 'left',
    { win = 'input', height = 1, border = 'bottom' },
    {
      box = 'horizontal',
      { win = 'list', border = 'none' },
      {
        win = 'preview',
        title = '{preview}',
        width = M.layout_config.preview_width,
        border = 'left',
      },
    },
  },
}

-- }}}

-- {{{ Wrapper Functions -------------------------------------------------------------------------

-- Wrapper function to apply ivy layout to a picker
function M.with_ivy_layout(picker_func, opts)
  opts = opts or {}
  opts.layouts = {
    ivy = M.ivy_layout,
  }
  opts.layout = 'ivy'
  opts.matcher = {
    sort_empty = true,
    cwd_bonus = true,
    frecency = true,
    history_bonus = true,
  }
  picker_func(opts)
end

-- Wrapper for the grep picker using ripgrep with custom args
function M.grep_with_ripgrep(opts)
  opts = opts or {}

  -- Remove the initial 'rg' from args since it's in cmd
  local grep_args = vim.list_extend({}, M.ripgrep_args)

  -- Merge passed options with our defaults
  opts.cmd = 'rg'
  opts.args = grep_args
  opts.layout = 'ivy'
  opts.layouts = {
    ivy = M.ivy_layout,
  }

  Snacks.picker.grep(opts)
end

-- Wrapper for the find files picker or smart picker using fd with custom args
function M.picker_with_fd(picker_func, opts)
  opts = opts or {}
  opts.cmd = 'fd'
  opts.args = M.fd_args
  M.with_ivy_layout(picker_func, opts)
end

-- }}}

-- {{{ Helper Function for Buffers Picker --------------------------------------------------------

-- Helper function to configure and show the buffers picker
function M.buffers_picker(opts)
  opts = opts or {}
  Snacks.picker.buffers({
    -- I always want my buffers picker to start in normal mode
    on_show = function()
      vim.cmd.stopinsert()
    end,
    finder = 'buffers',
    format = 'buffer',
    hidden = false,
    unloaded = true,
    current = true,
    sort_lastused = true,
    win = {
      input = {
        keys = {
          ['d'] = 'bufdelete',
        },
      },
      list = { keys = { ['d'] = 'bufdelete' } },
    },
    -- In case you want to override the layout for this keymap
    layout = 'ivy',
  })
end

-- }}}

-- {{{ Keymap Configuration -----------------------------------------------------------------------

-- Function to set up all picker-related keymaps
function M.setup_keymaps()
  -- Helper function for key mapping
  local function keymap(key, picker_func, opts)
    opts = opts or {}
    vim.keymap.set('n', key, function()
      picker_func(opts)
    end, { noremap = true, silent = true, desc = opts.desc or '' })
  end

  -- Top Pickers & Explorer
  keymap('<leader><space>', function()
    M.picker_with_fd(Snacks.picker.smart)
  end, { desc = '[s]mart [F]ind Files' })
  keymap('<leader>,', function()
    M.buffers_picker()
  end, { desc = '[b]uffers' })
  keymap('<leader>/', function()
    M.grep_with_ripgrep()
  end, { desc = '[g]rep' })
  keymap('<leader>:', function()
    M.with_ivy_layout(Snacks.picker.command_history)
  end, { desc = '[c]ommand [h]istory' })
  keymap('<leader>fe', function()
    Snacks.explorer()
  end, { desc = '[f]ile [e]xplorer' })
  keymap('<leader>lg', function()
    Snacks.lazygit()
  end, { desc = '[l]azy [g]it' })

  -- Find Pickers
  keymap('<leader>fb', function()
    M.buffers_picker()
  end, { desc = '[f]ind [b]uffers' })
  keymap('<leader>fc', function()
    M.with_ivy_layout(Snacks.picker.files, { cwd = vim.fn.stdpath('config') })
  end, { desc = '[f]ind [c]onfig file' })
  keymap('<leader>ff', function()
    M.picker_with_fd(Snacks.picker.files)
  end, { desc = '[f]ind [f]iles' })

  -- Grep Pickers with ripgrep arguments
  keymap('<leader>sg', function()
    M.grep_with_ripgrep()
  end, { desc = '[s]earch [g]rep' })
  keymap('<leader>sw', function()
    M.with_ivy_layout(Snacks.picker.grep_word)
  end, { desc = '[s]earch selected [w]ord', mode = { 'n', 'x' } })

  -- Search
  keymap('<leader>s"', function()
    M.with_ivy_layout(Snacks.picker.registers)
  end, { desc = '[s]earch [r]egisters' })
  keymap('<leader>sd', function()
    M.with_ivy_layout(Snacks.picker.diagnostics)
  end, { desc = '[s]earch [d]iagnostics' })
  keymap('<leader>sh', function()
    M.with_ivy_layout(Snacks.picker.help)
  end, { desc = '[s]earch [h]elp pages' })
  keymap('<leader>si', function()
    M.with_ivy_layout(Snacks.picker.icons)
  end, { desc = '[s]earch [i]cons' })
  keymap('<leader>sk', function()
    M.with_ivy_layout(Snacks.picker.keymaps)
  end, { desc = '[s]earch [k]eymaps' })
  keymap('<leader>sq', function()
    M.with_ivy_layout(Snacks.picker.qflist)
  end, { desc = '[s]earch [q]uickfix list' })
  keymap('<leader>sn', function()
    M.with_ivy_layout(Snacks.picker.notifications)
  end, { desc = '[s]earch [n]otification history' })
  keymap('<leader>st', function()
    M.with_ivy_layout(Snacks.picker.todo_comments)
  end, { desc = '[s]earch [t]odo comments' })
  keymap('<leader>pc', function()
    M.with_ivy_layout(Snacks.picker.colorschemes)
  end, { desc = '[p]ick [c]olorscheme' })
end

-- }}}

return M
