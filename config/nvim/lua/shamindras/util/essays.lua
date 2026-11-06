-- essays.lua — shamindras.com posts from Neovim
--
-- Thin wrappers over the site's `just` recipes in the main checkout,
-- $DROPBOX_REPOS_DIR/ss_personal_website. Posts live in per-post worktrees
-- under .worktrees/<short>; a running preview writes its URL to
-- .cache/preview-url. Keymaps live in plugins/essays.lua; the shell twins
-- are `just new`, `just open`, `just preview` and `just prose`, and the
-- sesh `blog` session runs `just preview` in its preview window.

local M = {}

-- {{{ Config

local REPO = 'ss_personal_website'
local NOTIFY_MS = 2000
local SPLIT_HEIGHT = 15

-- }}}

-- {{{ Helpers

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { timeout = NOTIFY_MS })
end

-- The site's main checkout, or nil (with a warning) when it is missing.
local function repo()
  local dir = (vim.env.DROPBOX_REPOS_DIR or (vim.env.HOME .. '/Dropbox/repos')) .. '/' .. REPO
  if vim.fn.isdirectory(dir) == 0 then
    notify('No site checkout at ' .. dir, vim.log.levels.WARN)
    return nil
  end
  return dir
end

-- The checkout holding the current buffer (a post's worktree or main).
local function buffer_root()
  return vim.fs.root(0, { 'justfile' })
end

-- Front matter `short:` of the current buffer, or nil.
local function current_short()
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 40, false)) do
    local short = line:match('^short:%s*["\']?([%w%-]+)')
    if short then
      return short
    end
  end
  return nil
end

local function read_preview_url(dir)
  local fh = dir and io.open(dir .. '/.cache/preview-url', 'r')
  if not fh then
    return nil
  end
  local url = fh:read('*l')
  fh:close()
  return url
end

-- Run a `just` recipe of the site in a terminal split at the bottom.
local function just_in_split(args, dir)
  dir = dir or repo()
  if not dir then
    return
  end
  vim.cmd('botright ' .. SPLIT_HEIGHT .. 'split')
  vim.fn.jobstart(vim.list_extend({ 'just', '--justfile', dir .. '/justfile' }, args), { term = true, cwd = dir })
  vim.cmd.startinsert()
end

-- Ivy-layout Snacks picker shared by eo and en: `items` need `text` (and
-- `file` for the preview); `on_pick` gets the chosen item.
local function pick(title, items, on_pick, opts)
  for idx, item in ipairs(items) do
    item.idx = idx
  end
  Snacks.picker(vim.tbl_extend('force', {
    title = title,
    items = items,
    sort = { fields = { 'score:desc', 'idx' } },
    layout = 'ivy',
    layouts = { ivy = require('shamindras.plugins.snacks.pickers').ivy_layout },
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.schedule(function()
          on_pick(item)
        end)
      end
    end,
  }, opts or {}))
end

-- }}}

-- {{{ Actions

-- <leader>ep: the current post on the running preview: its worktree's
-- preview first, else the whole-site preview in the main checkout.
function M.preview()
  local url = read_preview_url(buffer_root()) or read_preview_url(repo())
  if not url then
    notify('No preview running: `just preview` in the blog session', vim.log.levels.WARN)
    return
  end
  local short = current_short()
  if short then
    url = url:match('^(https?://[^/]+)') .. '/pst-' .. short .. '/'
  end
  local _, err = vim.ui.open(url)
  if err then
    notify(err, vim.log.levels.ERROR)
  end
end

-- <leader>eo: every post (on the go first), from `just posts --all --plain`.
function M.pick_post()
  local dir = repo()
  if not dir then
    return
  end
  local cmd = { 'just', '--justfile', dir .. '/justfile', 'posts', '--all', '--plain' }
  local out = vim.system(cmd, { text = true }):wait()
  local items = {}
  for line in vim.gsplit(out.stdout or '', '\n', { trimempty = true }) do
    local short, state, title, file = line:match('^(.-)|(.-)|(.-)|(.*)$')
    if short then
      items[#items + 1] = { text = title .. ' ' .. short, title = title, state = state, file = file }
    end
  end
  pick('Posts', items, function(item)
    vim.cmd('edit ' .. vim.fn.fnameescape(item.file))
  end, {
    format = function(item)
      return { { item.title }, { '  ' .. item.state, 'SnacksPickerComment' } }
    end,
  })
end

-- <leader>en: pick a template (previewed), then `just new` asks the title,
-- short name and tags in a split.
function M.new()
  local dir = repo()
  if not dir then
    return
  end
  local items = {}
  for _, file in ipairs(vim.fn.glob(dir .. '/content/templates/*.md', false, true)) do
    local name = vim.fn.fnamemodify(file, ':t:r')
    if name ~= 'README' then
      items[#items + 1] = { text = name, file = file }
    end
  end
  pick('New Post From Template', items, function(item)
    just_in_split({ 'new', '--no-open', '--template', item.text }, dir)
  end, { format = 'text', preview = 'file' })
end

-- <leader>ec: the prose check (Australian spelling, house style) on the
-- current checkout's last build, which the running preview keeps fresh.
function M.check()
  just_in_split({ 'prose' }, buffer_root())
end

-- }}}

return M
