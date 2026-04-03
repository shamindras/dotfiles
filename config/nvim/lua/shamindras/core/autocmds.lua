-- {{{ Format Options

-- enforce consistent formatoptions across all filetypes
-- nvim defaults are 'tcqj'; we explicitly set all desired flags to be
-- self-documenting and guard against future default changes
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('SetFormatOptions', { clear = true }),
  pattern = { '*' },
  callback = function()
    -- auto-wrap text using textwidth
    vim.opt.formatoptions:prepend({ 't' })

    -- auto-wrap comments using textwidth
    vim.opt.formatoptions:prepend({ 'c' })

    -- allow formatting comments with `gq`
    vim.opt.formatoptions:prepend({ 'q' })

    -- remove comment leader when joining lines (e.g. J on two comment lines)
    vim.opt.formatoptions:prepend({ 'j' })

    -- indent past formatlistpat, not underneath it (better numbered list formatting)
    vim.opt.formatoptions:prepend({ 'n' })

    -- continue comments when pressing Enter in insert mode
    vim.opt.formatoptions:prepend({ 'r' })

    -- do not continue comments with `o` or `O` in normal mode
    vim.opt.formatoptions:remove({ 'o' })

    -- do not auto-format paragraphs on every text change (use linters instead)
    vim.opt.formatoptions:remove({ 'a' })

    -- do not use second line's indent for the rest of the paragraph
    vim.opt.formatoptions:remove({ '2' })
  end,
})

-- }}}

-- {{{ Yank Highlight

-- highlight yanked text with customizable duration
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 500, higroup = 'IncSearch', on_macro = true })
  end,
})

-- }}}

-- {{{ Tool Config Restarts

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

-- leader-key config
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { '*/leader-key/config.json' },
  command = 'execute \'silent !killall "Leader Key" 2>/dev/null; sleep 0.5; open -a "Leader Key"\'',
})

-- borders config
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { 'bordersrc' },
  command = "execute 'silent !brew services restart borders'",
})

-- sketchybar config
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { 'sketchybarrc', '*/sketchybar/colors.sh', '*/sketchybar/items/*.sh' },
  command = "execute 'silent !sketchybar --reload'",
})

-- }}}

-- {{{ Window Resize

-- }}}

-- {{{ Last Location Restore

-- Goto last location when opening a buffer, then top-align the view.
local go_last_location_buffer_group = vim.api.nvim_create_augroup('go_last_location_buffer', { clear = true })
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
      -- defer to run after render-markdown and treesitter finish adjusting the viewport
      vim.defer_fn(function()
        vim.cmd('normal! zt')
      end, 250)
    end
  end,
  group = go_last_location_buffer_group,
})

-- }}}

-- {{{ Close Filetypes with q

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
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buf = event.buf, silent = true })
  end,
})

-- }}}

-- {{{ Cursor Line (Active Window Only)

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

-- }}}

-- {{{ Auto Create Directory on Save
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

-- }}}

-- {{{ Help Vertical Split

-- open help buffers in a vertical split (right side via splitright)
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = vim.api.nvim_create_augroup('HelpVerticalSplit', { clear = true }),
  callback = function()
    if vim.bo.buftype == 'help' then
      vim.cmd('wincmd L')
    end
  end,
})

-- }}}

-- {{{ Large File Detection

-- disable expensive features for large files to prevent freezes
local large_file_threshold = 1.5 * 1024 * 1024 -- 1.5 MB
vim.api.nvim_create_autocmd('BufReadPre', {
  group = vim.api.nvim_create_augroup('LargeFileDetection', { clear = true }),
  callback = function(event)
    local file = event.match
    local size = vim.fn.getfsize(file)
    if size <= large_file_threshold or size == -2 then
      return
    end
    vim.b[event.buf].large_file = true
    vim.notify(
      ('Large file detected (%s) — disabling treesitter, LSP, syntax'):format(vim.fn.fnamemodify(file, ':t')),
      vim.log.levels.WARN
    )
    vim.cmd('syntax off')
    vim.opt_local.foldmethod = 'manual'
    vim.opt_local.swapfile = false
    vim.opt_local.undolevels = -1
    vim.schedule(function()
      vim.treesitter.stop(event.buf)
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = event.buf })) do
        vim.lsp.buf_detach_client(event.buf, client.id)
      end
    end)
  end,
})

-- }}}

-- {{{ Window Separator Highlight

-- theme-aware separator: looks up the active colorscheme in the theme registry
-- and applies its separator_fg color. Falls back to white if theme is unknown.
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('WinSeparatorHighlight', { clear = true }),
  pattern = '*',
  callback = function()
    local themes = require('shamindras.util.themes')
    local key = themes.scheme_to_key[vim.g.colors_name]
    local fg = 'white'
    if key and themes.themes[key] and themes.themes[key].separator_fg then
      fg = themes.themes[key].separator_fg
    end
    vim.api.nvim_set_hl(0, 'WinSeparator', { bg = 'None', fg = fg })
  end,
})

-- }}}
