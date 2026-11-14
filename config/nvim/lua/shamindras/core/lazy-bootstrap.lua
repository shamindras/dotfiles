-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
  -- The clone is lazy.nvim's stable tag. Move it to the commit pinned in
  -- lazy-lock.json, or the first start rewrites the tracked lockfile.
  local ok, lock = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath('config') .. '/lazy-lock.json'), '\n'))
  end)
  local pin = ok and lock['lazy.nvim'] and lock['lazy.nvim'].commit
  if pin then
    vim.fn.system({ 'git', '-C', lazypath, 'checkout', '--quiet', pin })
  end
end
vim.opt.rtp:prepend(lazypath)
