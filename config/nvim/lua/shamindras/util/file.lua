-- file.lua — buffer-backed file operations shared by <leader>br and the
-- scratch module (util/scratch.lua).

local M = {}

-- {{{ Rename

-- Rename the file in the current buffer on disk and swap the buffer over
-- to the new path. Returns true on success.
---@param old_name string path as the buffer knows it
---@param new_name string target path
---@return boolean
function M.rename_to(old_name, new_name)
  local ok, err = pcall(vim.fn.rename, old_name, new_name)
  if not ok then
    vim.notify('Rename failed: ' .. err, vim.log.levels.ERROR)
    return false
  end
  if err ~= 0 then
    vim.notify('Rename failed: ' .. old_name .. ' → ' .. new_name, vim.log.levels.ERROR)
    return false
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(new_name))
  vim.cmd('bdelete ' .. vim.fn.bufnr(old_name))
  vim.notify('Renamed: ' .. old_name .. ' → ' .. new_name)
  return true
end

-- Prompt for a new name (pre-filled with the current path) and rename.
-- This is the <leader>br flow.
function M.rename_prompt()
  local old_name = vim.fn.expand('%')
  if old_name == '' then
    vim.notify('No file to rename', vim.log.levels.WARN)
    return
  end

  local new_name = vim.fn.input('New name: ', old_name, 'file')

  if new_name == '' or new_name == old_name then
    return
  end

  M.rename_to(old_name, new_name)
end

-- }}}

return M
