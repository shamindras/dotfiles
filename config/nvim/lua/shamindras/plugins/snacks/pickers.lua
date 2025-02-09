local M = {}
local Snacks = require 'snacks'

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
  '--no-ignore-vcs',
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
  'rg',
  '--color=never',
  '--no-heading',
  '--with-filename',
  '--line-number',
  '--column',
  '--smart-case',
  '--hidden',
  '--glob=!.git/*',
  '--glob=!node_modules/*',
  '--no-ignore-vcs',
  '--no-ignore-parent',
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
  table.remove(grep_args, 1)

  -- Merge passed options with our defaults
  opts.cmd = 'rg'
  opts.args = grep_args
  opts.layout = 'ivy'
  opts.layouts = {
    ivy = M.ivy_layout,
  }

  Snacks.picker.grep(opts)
end

-- Wrapper for the find files picker using fd with custom args
function M.find_files_with_fd(opts)
  opts = opts or {}
  opts.cmd = 'fd'
  opts.args = M.fd_args
  M.with_ivy_layout(Snacks.picker.files, opts)
end

-- Wrapper for the smart picker to exclude the same directories as fd_args
function M.smart_with_exclusions(opts)
  opts = opts or {}
  opts.cmd = 'fd'
  opts.args = M.fd_args
  M.with_ivy_layout(Snacks.picker.smart, opts)
end

-- }}}

-- {{{ Keymap Configuration -----------------------------------------------------------------------

-- Function to set up all picker-related keymaps
function M.setup_keymaps()
  -- Helper function for key mapping
  local function map_key(key, picker_func, opts)
    opts = opts or {}
    vim.keymap.set('n', key, function()
      picker_func(opts)
    end, { noremap = true, silent = true, desc = opts.desc or '' })
  end

  -- Top Pickers & Explorer
  map_key('<leader><space>', function()
    M.smart_with_exclusions()
  end, { desc = '[s]mart [F]ind Files' })
  map_key('<leader>,', function()
    M.with_ivy_layout(Snacks.picker.buffers)
  end, { desc = '[b]uffers' })
  map_key('<leader>/', function()
    M.grep_with_ripgrep()
  end, { desc = '[g]rep' })
  map_key('<leader>:', function()
    M.with_ivy_layout(Snacks.picker.command_history)
  end, { desc = '[c]ommand [h]istory' })
  map_key('<leader>nh', function()
    M.with_ivy_layout(Snacks.picker.notifications)
  end, { desc = '[n]otifications' })
  map_key('<leader>e', function()
    Snacks.explorer()
  end, { desc = '[f]ile [e]xplorer' })
  map_key('<leader>lg', function()
    Snacks.lazygit()
  end, { desc = '[l]azy [g]it' })

  -- Find Pickers
  map_key('<leader>fb', function()
    M.with_ivy_layout(Snacks.picker.buffers)
  end, { desc = '[f]ind [b]uffers' })
  map_key('<leader>fc', function()
    M.with_ivy_layout(Snacks.picker.files, { cwd = vim.fn.stdpath 'config' })
  end, { desc = '[f]ind [c]onfig file' })
  map_key('<leader>ff', function()
    M.with_ivy_layout(Snacks.picker.files)
  end, { desc = '[f]ind [f]iles' })
  map_key('<leader>fg', function()
    M.with_ivy_layout(Snacks.picker.git_files)
  end, { desc = '[f]ind [g]it files' })
  map_key('<leader>fp', function()
    M.with_ivy_layout(Snacks.picker.projects)
  end, { desc = '[f]ind [p]rojects' })
  map_key('<leader>fr', function()
    M.with_ivy_layout(Snacks.picker.recent)
  end, { desc = '[f]ind [r]ecent files' })

  -- Grep Pickers with ripgrep arguments
  map_key('<leader>sg', function()
    M.grep_with_ripgrep()
  end, { desc = '[s]earch [g]rep' })
  map_key('<leader>sw', function()
    M.with_ivy_layout(Snacks.picker.grep_word)
  end, { desc = '[s]earch selected [w]ord', mode = { 'n', 'x' } })

  -- Search
  map_key('<leader>s"', function()
    M.with_ivy_layout(Snacks.picker.registers)
  end, { desc = '[s]earch [r]egisters' })
  map_key('<leader>sb', function()
    M.with_ivy_layout(Snacks.picker.lines)
  end, { desc = '[s]earch [b]uffer lines' })
  map_key('<leader>sc', function()
    M.with_ivy_layout(Snacks.picker.command_history)
  end, { desc = '[s]earch [c]ommand history' })
  map_key('<leader>sC', function()
    M.with_ivy_layout(Snacks.picker.commands)
  end, { desc = '[s]earch [C]ommands' })
  map_key('<leader>sd', function()
    M.with_ivy_layout(Snacks.picker.diagnostics)
  end, { desc = '[s]earch [d]iagnostics' })
  map_key('<leader>sD', function()
    M.with_ivy_layout(Snacks.picker.diagnostics_buffer)
  end, { desc = '[s]earch [D]iagnostics (buffer)' })
  map_key('<leader>sh', function()
    M.with_ivy_layout(Snacks.picker.help)
  end, { desc = '[s]earch [h]elp pages' })
  map_key('<leader>si', function()
    M.with_ivy_layout(Snacks.picker.icons)
  end, { desc = '[s]earch [i]cons' })
  map_key('<leader>sk', function()
    M.with_ivy_layout(Snacks.picker.keymaps)
  end, { desc = '[s]earch [k]eymaps' })
  map_key('<leader>sl', function()
    M.with_ivy_layout(Snacks.picker.loclist)
  end, { desc = '[s]earch [l]ocation list' })
  map_key('<leader>sM', function()
    M.with_ivy_layout(Snacks.picker.man)
  end, { desc = '[s]earch [M]an pages' })
  map_key('<leader>sq', function()
    M.with_ivy_layout(Snacks.picker.qflist)
  end, { desc = '[s]earch [q]uickfix list' })
end

-- }}}

return M
