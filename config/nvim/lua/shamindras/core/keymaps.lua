-- Keymaps

-- {{{ custom keymap helper

-- keymap helper, which sets default options for silent and noremap to true
local function keymap(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  opts.noremap = opts.noremap ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ------------------------------------------------------------------------- }}}

-- {{{ buffers

-- save file
keymap(
  { 'i', 'x', 'n', 's' },
  '<C-s>',
  "<cmd>w<cr><esc><cmd>echo 'Saved ' . @%<cr>",
  { desc = 'Save File' }
)

-- TODO: integrate these once snacks.nvim is installed
-- source: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua#L40-L46
keymap('n', '<leader>bb', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
keymap('n', '<leader>bd', '<cmd>:bd<cr>', { desc = 'Delete Buffer and Window' })

-- ------------------------------------------------------------------------- }}}

-- {{{ lua interactive e[x]ecution

keymap(
  'n',
  '<leader>bx',
  "<cmd>w<cr><cmd>luafile %<cr><cmd>echo 'Sourced ' . @%<cr>",
  { desc = 'write and [b]uffer e[x]ecute' }
)
keymap('n', '<leader>x', '<cmd>.lua<CR>')
keymap('v', '<leader>x', '<cmd>.lua<CR>')

-- ------------------------------------------------------------------------- }}}

-- {{{ macros

-- quickly executing macros with the q register
keymap('n', 'Q', '@q')
keymap('v', 'Q', '<cmd>norm @q<cr>')

-- ------------------------------------------------------------------------- }}}

-- {{{ editing text

-- delete/change single character without copying into register
keymap('n', 'x', '"_x')
keymap('n', 'X', '"_X')
keymap('n', 'c', '"_c')
keymap('n', 'C', '"_C')

-- don't leave visual mode after indenting
keymap('v', '>', '>gv^')
keymap('v', '<', '<gv^')

-- change in word
keymap('n', '<C-c>', 'ciw')

-- ------------------------------------------------------------------------- }}}

-- {{{ navigation

-- better up/down
keymap({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true })
keymap({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true })
keymap({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true })
keymap({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true })

-- Map H and L to ^ and $, respectively
-- source: https://github.com/famiu/dot-nvim/blob/d7922d6ce9d9483cd68c67abb883e8ab91a17e4f/lua/keybinds.lua#L4-L6
-- TODO: check if the `H` and `L` can be used as operators, e.g. `dH` deletes to beginning of line.
keymap('n', 'H', '^')
keymap('n', 'L', '$')

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
keymap('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
keymap('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
keymap('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
keymap('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' })
keymap('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
keymap('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })

-- ------------------------------------------------------------------------- }}}

-- {{{ windows and splits

---Toggle the maximization state of the current window.
---Maximizes the window if it's not maximized, restores the previous layout if it is.
---Preserves the cursor and scroll position of the window.
---@return nil
local function toggle_window_maximize()
  local current_win = vim.api.nvim_get_current_win()
  local current_view = vim.fn.winsaveview()

  -- Store the current window configuration
  local is_maximized = vim.t.maximized_window == current_win

  if is_maximized then
    -- Restore the previous window layout
    vim.cmd 'wincmd ='
    vim.t.maximized_window = nil
  else
    -- Maximize the current window
    vim.cmd 'wincmd |' -- Maximize vertically
    vim.cmd 'wincmd _' -- Maximize horizontally
    vim.t.maximized_window = current_win
  end

  -- Restore the view (cursor position, scroll position, etc.)
  vim.fn.winrestview(current_view)
end

-- window management
keymap('n', '<leader>we', '<C-w>=') -- make split windows equal width & height
keymap('n', '<leader>wh', '<C-w>s') -- split window horizontally
keymap('n', '<leader>wm', toggle_window_maximize) -- toggle maximize active window
keymap('n', '<leader>wv', '<C-w>v') -- split window vertically
keymap('n', '<leader>wx', '<cmd>close<CR>') -- close current split window

-- ------------------------------------------------------------------------- }}}

-- {{{ yanking and selecting

-- keymap('n', 'Y', 'yg$') -- yank up to the end of visual line
-- keymap('n', '<leader>yl', 'yg$') -- yank up to the end of visual line
-- keymap('n', '<leader>yh', 'yg^') -- yank up to the beginning of visual line
keymap('n', 'J', 'mzJ`z')
keymap('n', '<C-d>', '<C-d>zz')
keymap('n', '<C-u>', '<C-u>zz')

-- greatest remap ever
keymap('x', '<leader>p', '"_dP')

-- next greatest remap ever : asbjornHaland
keymap('n', '<leader>y', '"+y')
keymap('v', '<leader>y', '"+y')
keymap('n', '<leader>Y', '"+Y')
keymap('n', '<leader>yb', '<cmd>%y+<CR>')

keymap('n', '<leader>d', '"_d')
keymap('v', '<leader>d', '"_d')
keymap(
  'n',
  '<leader>bl',
  '<cmd>%d _<CR>',
  { noremap = true, desc = 'Clear buffer without copying' }
)
keymap(
  'n',
  '<leader>bc',
  '<cmd>%d<CR>',
  { noremap = true, desc = 'Clear buffer and copy contents' }
)

-- ------------------------------------------------------------------------- }}}

-- {{{ insert missing lines above/below

-- source: https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/basics.lua#L576-L577
-- NOTE: does not support `.` repeat
keymap('n', 'gO', "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>")
keymap('n', 'go', "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>")

-- ------------------------------------------------------------------------- }}}

-- {{{ Folding commands.

-- Author: Karl Yngve Lervåg
--    See: https://github.com/lervag/dotnvim

-- Close all fold except the current one.
keymap('n', 'zv', 'zMzvzz', { desc = 'Close all folds except current' })

-- Close current fold when open. Always open next fold.
keymap('n', 'zj', 'zcjzOzz', { desc = 'Close fold & open next one' })

-- Close current fold when open. Always open previous fold.
keymap('n', 'zk', 'zckzOzz', { desc = 'Close fold & open previous one' })

-- ------------------------------------------------------------------------- }}}

-- {{{ lazy.nvim keymaps

-- source: lazy.nvim default keymaps integrated with folke/lazy.nvim
keymap('n', '<leader>ll', '<cmd>Lazy<cr>', { desc = '[L]azy Menu' })
keymap('n', '<leader>lu', '<cmd>Lazy update<cr>', { desc = '[L]azy [U]pdate' })
keymap('n', '<leader>ls', '<cmd>Lazy sync<cr>', { desc = '[L]azy [S]ync' })
keymap('n', '<leader>lc', '<cmd>Lazy clean<cr>', { desc = '[L]azy [C]lean' })
keymap('n', '<leader>lx', '<cmd>Lazy check<cr>', { desc = '[L]azy Check' })
keymap('n', '<leader>li', '<cmd>Lazy install<cr>', { desc = '[L]azy [I]nstall' })
keymap('n', '<leader>lp', '<cmd>Lazy profile<cr>', { desc = '[L]azy [P]rofile' })
keymap('n', '<leader>lr', '<cmd>Lazy restore<cr>', { desc = '[L]azy [R]estore' })
keymap('n', '<leader>ld', '<cmd>Lazy debug<cr>', { desc = '[L]azy [D]ebug' })

-- ------------------------------------------------------------------------- }}}
