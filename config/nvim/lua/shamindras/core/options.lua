-- {{{ Boilerplate

local o = vim.o
local opt = vim.opt

-- }}}

-- {{{ Tabs & Indentation

o.tabstop = 2 -- 2 spaces for tabs (prettier default)
o.softtabstop = 2 -- how many columns of whitespace is a tab keypress or a backspace keypress worth
o.shiftwidth = 2 -- 2 spaces for indent width
o.expandtab = true -- expand tab to spaces
o.autoindent = true -- copy indent from current line when starting new one
o.smartindent = true
o.breakindent = true -- Enable break indent
o.backspace = 'indent,eol,start' -- allow backspace on indent, end of line or insert mode start position

-- }}}

-- {{{ Line Numbers

o.number = true -- show absolute line number on which cursor is on
o.relativenumber = true -- show relative line numbers

-- }}}

-- {{{ Appearance

o.cursorline = true -- show which line your cursor is on
o.ruler = false -- don't show cursor position in the command line
o.termguicolors = true -- enable terminal gui colors
o.showmode = false -- don't show the mode, since it is already in the status line
o.signcolumn = 'yes' -- always show signcolumn (otherwise it will shift text)
o.laststatus = 3 -- Use global statusline

-- }}}

-- {{{ Search

o.ignorecase = true -- Case-insensitive searching
o.smartcase = true -- unless \C or one or more capital letters in the search term
o.hlsearch = false
o.incsearch = true
o.inccommand = 'split' -- Preview substitutions live, as you type!

-- }}}

-- {{{ Timing

o.updatetime = 250 -- Decrease update time
o.timeoutlen = 300 -- Decrease mapped sequence wait time

-- }}}

-- {{{ Window Splits

o.splitright = true -- split vertical window to the right
o.splitbelow = true -- split horizontal window to the bottom

-- }}}

-- {{{ Backup & Undo

o.backup = false -- don't store backup while overwriting the file
o.writebackup = false -- don't store backup while overwriting the file
o.swapfile = false -- don't create swapfile
o.undodir = vim.fn.stdpath('state') .. '/undo'
o.undofile = true

-- }}}

-- {{{ Clipboard

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  o.clipboard = 'unnamedplus'
end)

-- }}}

-- {{{ Whitespace Display

-- NOTE: `opt` (vim.opt) is used here instead of `o` (vim.o) because these
-- options need table assignments or :append()/:remove() methods.
o.list = true -- show some helper symbols
opt.listchars = { tab = '> ', trail = '-', nbsp = '+' } -- define which helper symbols to show
opt.fillchars = { foldclose = ' ', fold = ' ', eob = ' ' }

-- }}}

-- {{{ Folding

o.foldlevel = 99
o.foldmethod = 'marker'

-- }}}

-- {{{ Miscellaneous

o.joinspaces = false -- don't use 2 spaces when joining sentences
o.scrolloff = 1 -- Minimal number of screen lines to keep above and below the cursor.
o.mouse = 'a' -- enable mouse mode, useful for resizing splits for example.
opt.shortmess:append('I') -- disable vim startup message
opt.iskeyword:append('-') -- consider string-string as whole word
vim.g.have_nerd_font = true

-- }}}
