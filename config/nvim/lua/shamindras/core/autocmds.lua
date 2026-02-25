-- disable automatic comment continuation for all file type in normal mode
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('DisableAutoComment', { clear = true }),
  pattern = { '*' },
  callback = function()
    -- let comments respect textwidth
    vim.opt.formatoptions:prepend({ 'c' })

    -- auto-remove comments if possible
    vim.opt.formatoptions:prepend({ 'j' })

    -- indent past the formatlistpat, not underneath it.
    vim.opt.formatoptions:prepend({ 'n' })

    -- allow formatting comments with `gq`
    vim.opt.formatoptions:prepend({ 'q' })

    -- continue comments when pressing enter in insert mode
    vim.opt.formatoptions:prepend({ 'r' })

    -- auto-wrap text using textwidth
    vim.opt.formatoptions:prepend({ 't' })

    -- do not continue comments with `O` or `o`
    vim.opt.formatoptions:remove({ 'o' })

    -- no need to use autoformat, use linters
    vim.opt.formatoptions:remove({ 'a' })

    -- TODO: add more details for this option
    vim.opt.formatoptions:remove({ '2' })
  end,
})

-- highlight yanked text with customizable duration
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 500, higroup = 'IncSearch', on_macro = true })
  end,
})

-- yazi config
-- source: https://github.com/joshmedeski/dotfiles/blob/d337bef32b58c46c857d19448b2949f9c11d6a1f/.config/nvim/lua/config/autocmds.lua
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { 'yazi.toml' },
  command = "execute 'silent !yazi --clear-cache'",
})

-- aerospace config
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { 'aerospace.toml' },
  command = "execute 'silent !aerospace reload-config'",
})

-- borders config
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { 'bordersrc' },
  command = "execute 'silent !brew services restart borders'",
})

-- resize splits if window got resized
local resize_window_group = vim.api.nvim_create_augroup('resize_window', { clear = true })
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  callback = function()
    vim.cmd('tabdo wincmd =')
  end,
  group = resize_window_group,
})

-- Goto last location when opening a buffer.
local go_last_location_buffer_group = vim.api.nvim_create_augroup('go_last_location_buffer', { clear = true })
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  group = go_last_location_buffer_group,
})

-- {{{ close some filetypes with <q>.

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('close_with_q', { clear = true }),
  pattern = {
    'Gru FAR',
    'PlenaryTestPopup',
    'checkhealth',
    'fugitive',
    'git',
    'help',
    'lazy',
    'lspinfo',
    'man',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'query',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
  end,
})

-- ------------------------------------------------------------------------- }}}

-- {{{ cursor line

-- show cursor line only in active window
vim.api.nvim_create_autocmd({ 'InsertLeave', 'WinEnter' }, {
  callback = function()
    if vim.w.auto_cursorline then
      vim.wo.cursorline = true
      vim.w.auto_cursorline = nil
    end
  end,
})
vim.api.nvim_create_autocmd({ 'InsertEnter', 'WinLeave' }, {
  callback = function()
    if vim.wo.cursorline then
      vim.w.auto_cursorline = true
      vim.wo.cursorline = false
    end
  end,
})

-- ------------------------------------------------------------------------- }}}

-- {{ Auto create dir when saving a file, in case some intermediate directory does not exist
-- source: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua#L116-L126
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = vim.api.nvim_create_augroup('auto_create_dir', { clear = true }),
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- ------------------------------------------------------------------------- }}}

-- {{{ WinSeparator color line

-- Add this at the end of your file
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    vim.api.nvim_set_hl(0, 'WinSeparator', { bg = 'None', fg = 'white' })
  end,
})

-- ------------------------------------------------------------------------- }}}
