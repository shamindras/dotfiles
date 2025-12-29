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
keymap({ 'i', 'x', 'n', 's' }, '<C-s>', "<cmd>w<cr><esc><cmd>echo 'Saved ' . @%<cr>", { desc = 'Save File' })

-- switch buffers
keymap('n', '<leader>bb', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })

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
keymap('n', '<C-c>', 'ciW')

-- Remap <Esc> in insert mode based on cursor position
vim.keymap.set('i', '<Esc>', function()
  return vim.fn.col('.') == 1 and '<Esc>' or '<Esc>l'
end, { expr = true, desc = 'Exit insert, move right' })

-- ------------------------------------------------------------------------- }}}

-- {{{ navigation

-- better up/down
keymap({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true })
keymap({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true })
keymap({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true })
keymap({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true })

-- mini.operators overrides default gx and moves it to gX for opening links
-- This mapping provides <leader>gx as an additional way to open links
-- If mini.operators is loaded, use its gX callback; otherwise fall back to default gx
keymap({ 'n', 'x' }, '<leader>gx', function()
  -- Check if mini.operators is loaded
  if _G.MiniOperators then
    -- mini.operators is loaded, use its gX callback (the preserved original gx)
    local gx_keymap = vim.fn.maparg('gX', 'n', false, true)
    if gx_keymap.callback then
      gx_keymap.callback()
    end
  else
    -- Fallback to default gx behavior
    vim.cmd('normal! gx')
  end
end, { desc = 'Open link under cursor' })

--- Map H and L to ^ and $ (beginning/end of line)
-- Works in normal mode for movement and operator-pending mode for motions (e.g., dH, yL)
keymap({ 'n', 'o' }, 'H', '^')
keymap({ 'n', 'o' }, 'L', '$')

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
    vim.cmd('wincmd =')
    vim.t.maximized_window = nil
  else
    -- Maximize the current window
    vim.cmd('wincmd |') -- Maximize vertically
    vim.cmd('wincmd _') -- Maximize horizontally
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
keymap('n', '<leader>bl', '<cmd>%d _<CR>', { noremap = true, desc = 'Clear buffer without copying' })
keymap('n', '<leader>bc', '<cmd>%d<CR>', { noremap = true, desc = 'Clear buffer and copy contents' })

-- ------------------------------------------------------------------------- }}}

-- {{{ Dot-repeatable empty line insertion

-- insert missing lines above/below
-- Source: https://github.com/nvim-mini/mini.basics
_G.put_empty_line = function(put_above)
  if type(put_above) == 'boolean' then
    vim.o.operatorfunc = 'v:lua.put_empty_line'
    vim.g.put_empty_line_above = put_above
    return 'g@l'
  end

  local target_line = vim.fn.line('.') - (vim.g.put_empty_line_above and 1 or 0)
  vim.fn.append(target_line, vim.fn['repeat']({ '' }, vim.v.count1))
end

-- Keymaps
keymap('n', 'gO', 'v:lua.put_empty_line(v:true)', { expr = true, desc = 'Put empty line above' })
keymap('n', 'go', 'v:lua.put_empty_line(v:false)', { expr = true, desc = 'Put empty line below' })

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
keymap('n', '<leader>lp', '<cmd>Lazy profile<cr>', { desc = '[L]azy [P]rofile' })

-- ------------------------------------------------------------------------- }}}

-- {{{ Q/q - Quit

-- Quit all and Save All
keymap('n', '<leader>qa', '<cmd>qall!<cr>', { desc = 'Quit all!' })
keymap('n', '<leader>wa', '<cmd>wall!<cr>', { desc = 'Write quit all!' })

-- ------------------------------------------------------------------------- }}}

-- {{{ Line Number Toggle

-- Define the custom toggle function
local function custom_toggle_line_numbers()
  if vim.o.relativenumber then
    -- Switch to the two-column setup: absolute in left column, relative in right column
    vim.o.number = true
    vim.o.relativenumber = false
    vim.wo.numberwidth = 4 -- Set width for absolute numbers (left-most gutter)
    vim.wo.signcolumn = 'yes' -- Always show sign column (right-most gutter)
  else
    -- Switch back to the default 1-column setup: only relative numbers in the right column
    vim.o.number = true
    vim.o.relativenumber = true
    vim.wo.numberwidth = nil -- Do not show absolute numbers in the left-most gutter
    vim.wo.signcolumn = 'yes' -- Keep relative numbers in the right-most gutter
  end
end

-- Toggle between 1-column and 2-column line number setups
keymap('n', '<leader>tn', custom_toggle_line_numbers, { desc = 'Toggle line number setup' })

-- ------------------------------------------------------------------------- }}}
