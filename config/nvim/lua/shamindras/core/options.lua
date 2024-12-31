-- {{{ Useful options

-- tabs & indentation
vim.o.tabstop = 2 -- 4 spaces for tabs (prettier default)
vim.o.softtabstop = 2 -- how many columns of whitespace is a tab keypress or a backspace keypress worth
vim.o.shiftwidth = 2 -- 2 spaces for indent width
vim.o.expandtab = true -- expand tab to spaces
vim.o.autoindent = true -- copy indent from current line when starting new one
vim.o.smartindent = true
vim.o.breakindent = true -- Enable break indent
vim.o.backspace = 'indent,eol,start' -- allow backspace on indent, end of line or insert mode start position

-- numbering
vim.o.number = true -- show absolute line number on which cursor is on
vim.o.relativenumber = true -- show relative line numbers

-- appearance
vim.o.showmode = false -- don't show the mode, since it is already in the status line
vim.o.signcolumn = 'yes' -- Keep signcolumn on by default
vim.o.cursorline = true -- Show which line your cursor is on

-- search
vim.o.ignorecase = true -- Case-insensitive searching 
vim.o.smartcase = true -- unless \C or one or more capital letters in the search term
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.inccommand = 'split' -- Preview substitutions live, as you type!

-- update time
vim.o.updatetime = 250 -- Decrease update time
vim.o.timeoutlen = 300 -- Decrease mapped sequence wait time

-- window splits
vim.o.splitright = true -- split vertical window to the right
vim.o.splitbelow = true -- split horizontal window to the bottom

-- backup
vim.o.backup = false
vim.o.swapfile = false
vim.o.undodir = os.getenv("HOME") .. "/.local/state/nvim/undo"
vim.o.undofile = true

-- misc
vim.o.joinspaces = false -- don't use 2 spaces when joining sentences
vim.o.scrolloff = 10 -- Minimal number of screen lines to keep above and below the cursor.
vim.o.mouse = 'a' -- enable mouse mode, useful for resizing splits for example.

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- ------------------------------------------------------------------------- }}}

vim.opt.shortmess:append('I') -- disable vim startup message
vim.opt.iskeyword:append('-') -- consider string-string as whole word

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--  TODO: check why `vim.o` does not work here. Currently requires `vim.opt`.
vim.opt.list = true
vim.opt.listchars = { tab = '> ', trail = '-', nbsp = '+' }

vim.g.have_nerd_font = true

