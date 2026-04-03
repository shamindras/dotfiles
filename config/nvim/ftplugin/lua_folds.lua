-- Lua fold auto-collapse: close all marker folds on buffer open,
-- then open only the fold containing the cursor.

-- {{{ Auto-collapse on Buffer Load

local bufnr = vim.api.nvim_get_current_buf()

-- Guard: skip if large file detection disabled folding
if vim.b.large_file then
  return
end

vim.api.nvim_create_autocmd('BufWinEnter', {
  buffer = bufnr,
  once = true,
  callback = function()
    vim.defer_fn(function()
      if not vim.api.nvim_buf_is_valid(bufnr) or vim.api.nvim_get_current_buf() ~= bufnr then
        return
      end

      -- Verify folds exist (foldmethod=marker should create them)
      local has_folds = false
      for i = 1, vim.fn.line('$') do
        if vim.fn.foldlevel(i) > 0 then
          has_folds = true
          break
        end
      end
      if not has_folds then
        return
      end

      -- Save cursor (already restored by Last Location Restore autocmd)
      local saved_cursor = vim.api.nvim_win_get_cursor(0)

      -- Collapse all folds, then open just enough to reveal cursor line
      vim.cmd('normal! zM')
      vim.api.nvim_win_set_cursor(0, saved_cursor)
      vim.cmd('normal! zvzz')
    end, 100)
  end,
})

-- }}}
