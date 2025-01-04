-- Keymaps
-- Most of these are sourced from lazyvim: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

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
keymap({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc><cmd>echo 'Saved ' . @%<cr>", { desc = "Save File" })

-- TODO: integrate these once snacks.nvim is installed
-- source: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua#L40-L46
-- TODO: replace the `[b` and `]b` using `mini.move()`
-- keymap("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
-- keymap("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
keymap("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
keymap("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
keymap("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- ------------------------------------------------------------------------- }}}

-- {{{ lua interactive e[x]ecution

keymap(
	"n",
	"<leader>bx",
	"<cmd>w<cr><cmd>luafile %<cr><cmd>echo 'Sourced ' . @%<cr>",
	{ desc = "write and [b]uffer e[x]ecute" }
)
keymap("n", "<leader>x", "<cmd>.lua<CR>")
keymap("v", "<leader>x", "<cmd>.lua<CR>")

-- ------------------------------------------------------------------------- }}}

-- {{{ macros

-- quickly executing macros with the q register
keymap("n", "Q", "@q")
keymap("v", "Q", "<cmd>norm @q<cr>")

-- ------------------------------------------------------------------------- }}}

-- {{{ editing text

-- delete/change single character without copying into register
keymap("n", "x", '"_x')
keymap("n", "X", '"_X')
keymap("n", "c", '"_c')
keymap("n", "C", '"_C')

-- don't leave visual mode after indenting
keymap("v", ">", ">gv^")
keymap("v", "<", "<gv^")

-- commenting
-- TODO: replace with `mini.comment()`
-- keymap("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
-- keymap("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- move Lines
-- TODO: get the `A` key mapped to left option key in macOS on wezterm
--       currently we use `CMD+Option` on macOS keyboard.
-- keymap("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
-- keymap("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
-- keymap("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
-- keymap("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
-- keymap("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
-- keymap("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- ------------------------------------------------------------------------- }}}

-- {{{ navigation

-- better up/down
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true })
keymap({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true })
keymap({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true })

-- Map H and L to ^ and $, respectively
-- source: https://github.com/famiu/dot-nvim/blob/d7922d6ce9d9483cd68c67abb883e8ab91a17e4f/lua/keybinds.lua#L4-L6
-- TODO: check if the `H` and `L` can be used as operators, e.g. `dH` deletes to beginning of line.
-- keymap('n', 'H', '^')
-- keymap('n', 'L', '$')

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
keymap("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
keymap("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
keymap("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
keymap("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
keymap("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
keymap("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Move to window using the <ctrl> hjkl keys
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true, noremap = false })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true, noremap = false })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true, noremap = false })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true, noremap = false })

-- ------------------------------------------------------------------------- }}}

-- {{{ windows

-- window management
-- TODO: add window maximizer toggle
keymap('n', '<leader>wv', '<C-w>v') -- split window vertically
keymap('n', '<leader>wh', '<C-w>s') -- split window horizontally
keymap('n', '<leader>we', '<C-w>=') -- make split windows equal width & height
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

keymap('n', '<leader>d', '"_d')
keymap('v', '<leader>d', '"_d')

-- ------------------------------------------------------------------------- }}}
