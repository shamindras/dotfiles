-- ~/.config/nvim/lua/plugins/snacks/pickers.lua
local M = {}

-- Layout configuration
M.layout_config = {
  height = 0.7,
  preview_width = 0.6,
}

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
-- Custom ripgrep args for the grep picker (fixed glob patterns)
M.ripgrep_args = {
  'rg',
  '--color=never',
  '--no-heading',
  '--with-filename',
  '--line-number',
  '--column',
  '--smart-case',
  '--hidden',
  '--glob=!.git/*', -- Removed extra quotes
  '--glob=!node_modules/*', -- Removed extra quotes
  '--no-ignore-vcs',
  '--no-ignore-parent',
  '--follow',
}

-- Custom ivy layout configuration
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

  local picker_opts = {
    cmd = 'rg',
    args = grep_args,
    layout = 'ivy',
    layouts = {
      ivy = M.ivy_layout,
    },
  }

  require('snacks').picker.grep(picker_opts)
end

-- Wrapper for the find files picker using fd with custom args
function M.find_files_with_fd(opts)
  opts = opts or {}
  opts.cmd = 'fd'
  opts.args = M.fd_args
  M.with_ivy_layout(require('snacks').picker.files, opts)
end

-- Wrapper for the smart picker to exclude the same directories as fd_args
function M.smart_with_exclusions(opts)
  opts = opts or {}
  opts.cmd = 'fd'
  opts.args = vim.list_extend(M.fd_args, {
    '--type',
    'f', -- Ensure it's only files (like fd)
    '--strip-cwd-prefix',
    '--hidden',
    '--no-ignore-vcs',
    '--exclude',
    '.git', -- Exclude .git directory
    '--exclude',
    'node_modules', -- Exclude node_modules directory
    '--exclude',
    'submods', -- Exclude submods directory
    '--follow',
  })

  M.with_ivy_layout(require('snacks').picker.smart, opts)
end

-- Function to set up all picker-related keymaps
function M.setup_keymaps()
  local Snacks = require 'snacks'

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
  map_key('<leader>s/', function()
    M.with_ivy_layout(Snacks.picker.search_history)
  end, { desc = '[s]earch [h]istory' })
  map_key('<leader>sa', function()
    M.with_ivy_layout(Snacks.picker.autocmds)
  end, { desc = '[s]earch [a]utocmds' })
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
  map_key('<leader>sH', function()
    M.with_ivy_layout(Snacks.picker.highlights)
  end, { desc = '[s]earch [H]ighlights' })
  map_key('<leader>si', function()
    M.with_ivy_layout(Snacks.picker.icons)
  end, { desc = '[s]earch [i]cons' })
  map_key('<leader>sj', function()
    M.with_ivy_layout(Snacks.picker.jumps)
  end, { desc = '[s]earch [j]umps' })
  map_key('<leader>sk', function()
    M.with_ivy_layout(Snacks.picker.keymaps)
  end, { desc = '[s]earch [k]eymaps' })
  map_key('<leader>sl', function()
    M.with_ivy_layout(Snacks.picker.loclist)
  end, { desc = '[s]earch [l]ocation list' })
  map_key('<leader>sm', function()
    M.with_ivy_layout(Snacks.picker.marks)
  end, { desc = '[s]earch [m]arks' })
  map_key('<leader>sM', function()
    M.with_ivy_layout(Snacks.picker.man)
  end, { desc = '[s]earch [M]an pages' })
  map_key('<leader>sp', function()
    M.with_ivy_layout(Snacks.picker.lazy)
  end, { desc = '[s]earch [p]lugin specs' })
  map_key('<leader>sq', function()
    M.with_ivy_layout(Snacks.picker.qflist)
  end, { desc = '[s]earch [q]uickfix list' })
  map_key('<leader>sR', function()
    M.with_ivy_layout(Snacks.picker.resume)
  end, { desc = '[s]earch [R]esume' })
  map_key('<leader>su', function()
    M.with_ivy_layout(Snacks.picker.undo)
  end, { desc = '[s]earch [u]ndo history' })
  map_key('<leader>uC', function()
    M.with_ivy_layout(Snacks.picker.colorschemes)
  end, { desc = '[u]ndo [C]olorschemes' })
end

return M
