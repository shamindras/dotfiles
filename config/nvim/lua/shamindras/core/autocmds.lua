-- disable automatic comment continuation for all file type in normal mode
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("DisableAutoComment", { clear = true }),
	pattern = { "*" },
	callback = function()
		vim.opt.formatoptions:remove({ "o" })
	end,
})

-- highlight yanked text with customizable duration
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ timeout = 500, higroup = "IncSearch", on_macro = true })
	end,
})

-- source: https://github.com/joshmedeski/dotfiles/blob/d337bef32b58c46c857d19448b2949f9c11d6a1f/.config/nvim/lua/config/autocmds.lua
-- yazi config
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "yazi.toml" },
	command = "execute 'silent !yazi --clear-cache'",
})

-- aerospace config
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "aerospace.toml" },
	command = "execute 'silent !aerospace reload-config'",
})

-- resize splits if window got resized
local resize_window_group = vim.api.nvim_create_augroup("resize_window", { clear = true })
vim.api.nvim_create_autocmd({ "VimResized" }, {
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
	group = resize_window_group,
})

-- Goto last location when opening a buffer.
local go_last_location_buffer_group = vim.api.nvim_create_augroup("go_last_location_buffer", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
	group = go_last_location_buffer_group,
})

-- {{{ Close some filetypes with <q>.

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
	pattern = {
		"Gru FAR",
		"PlenaryTestPopup",
		"checkhealth",
		"fugitive",
		"git",
		"help",
		"lspinfo",
		"man",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"query",
		"spectre_panel",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- ------------------------------------------------------------------------- }}}
