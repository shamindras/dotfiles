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
