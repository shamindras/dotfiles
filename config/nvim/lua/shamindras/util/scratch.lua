-- scratch.lua — low-latency markdown scratch notes
--
-- Plain .md files in $DROPBOX_NOTES_DIR/scratch (a sibling of the zk
-- notebook, never inside it). One optional title prompt: Enter saves as a
-- timestamp, a title saves as its slug. Keymaps live in
-- plugins/scratch.lua; the shell twin is config/bin/scratch-new.
--
-- Naming rule (keep in step with config/bin/scratch-new):
--   empty title → YYYY-MM-DD-HHMMSS.md, line 1 "# "
--   title       → <slug>.md (util/slug.lua), line 1 "# Title Case"

local slug = require('shamindras.util.slug')
local file = require('shamindras.util.file')

local M = {}

-- {{{ Config

local TIMESTAMP = '%Y-%m-%d-%H%M%S'
local NOTIFY_MS = 2000

-- }}}

-- {{{ Helpers

local function realpath(path)
  return vim.uv.fs_realpath(path) or path
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { timeout = NOTIFY_MS })
end

local function is_current_buffer(path)
  return realpath(path) == realpath(vim.api.nvim_buf_get_name(0))
end

-- First H1 text in `lines` (checks the first five lines), or nil.
local function first_heading(lines)
  for i = 1, math.min(#lines, 5) do
    local title = lines[i]:match('^#%s+(.-)%s*$')
    if title then
      return title
    end
  end
  return nil
end

local function read_heading(path)
  local lines = {}
  local fh = io.open(path, 'r')
  if not fh then
    return nil
  end
  for line in fh:lines() do
    lines[#lines + 1] = line
    if #lines >= 5 then
      break
    end
  end
  fh:close()
  return first_heading(lines)
end

-- "now", "3m", "2h", "4d"
local function relative_age(mtime)
  local diff = os.time() - mtime
  if diff < 60 then
    return 'now'
  elseif diff < 3600 then
    return string.format('%dm', math.floor(diff / 60))
  elseif diff < 86400 then
    return string.format('%dh', math.floor(diff / 3600))
  end
  return string.format('%dd', math.floor(diff / 86400))
end

-- }}}

-- {{{ Directory

-- Resolved scratch directory, created on first use.
---@return string
function M.dir()
  local notes = vim.env.DROPBOX_NOTES_DIR
  if not notes or notes == '' then
    notes = vim.fn.expand('~/Dropbox/notes')
  end
  local dir = notes .. '/scratch'
  vim.fn.mkdir(dir, 'p')
  return realpath(dir)
end

-- True when the buffer holds a .md file inside the scratch directory.
---@param bufnr? integer
---@return boolean
function M.in_scratch(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  if name == '' or not name:match('%.md$') then
    return false
  end
  return vim.startswith(realpath(name), M.dir() .. '/')
end

local function guard()
  if not M.in_scratch(0) then
    notify('Not a scratch note', vim.log.levels.WARN)
    return false
  end
  return true
end

-- }}}

-- {{{ Create / Open

-- Open `path`; `insert` places the cursor on line 3 in insert mode.
---@param path string
---@param verb? string notification verb ("Created" / "Opened")
---@param insert? boolean
function M.open(path, verb, insert)
  local filename = vim.fn.fnamemodify(path, ':t')
  if is_current_buffer(path) then
    notify('Already on scratch: ' .. filename)
    return
  end
  vim.cmd('edit ' .. vim.fn.fnameescape(path))
  if insert then
    local last = vim.api.nvim_buf_line_count(0)
    vim.api.nvim_win_set_cursor(0, { math.min(3, last), 0 })
    vim.cmd.startinsert()
  end
  if verb then
    vim.defer_fn(function()
      notify(verb .. ' scratch: ' .. filename)
    end, 100)
  end
end

-- Create (or reuse) a scratch for `title` and open it. Returns the path.
---@param title? string
---@return string
function M.new(title)
  local dir = M.dir()
  title = vim.trim(title or '')

  local name, heading
  if title ~= '' then
    name = slug.slugify(title)
  end
  if name and name ~= '' then
    heading = '# ' .. slug.to_title(name)
  else
    name = os.date(TIMESTAMP)
    heading = '# '
  end

  local path = dir .. '/' .. name .. '.md'
  if vim.uv.fs_stat(path) then
    M.open(path, 'Opened', true)
    return path
  end

  vim.fn.writefile({ heading, '', '' }, path)
  M.open(path, 'Created', true)
  return path
end

-- <leader>nn: prompt, then create. Enter on an empty prompt (or Esc, which
-- vim.fn.input cannot distinguish) makes a timestamp scratch; Ctrl-C aborts.
function M.prompt_new()
  vim.ui.input({ prompt = 'Scratch title: ' }, function(input)
    if input == nil then
      return
    end
    M.new(input)
  end)
end

-- }}}

-- {{{ List / Find

-- All scratch notes, newest first: { file, name, mtime, label }.
function M.list()
  local dir = M.dir()
  local items = {}
  for name, kind in vim.fs.dir(dir) do
    if kind == 'file' and name:match('%.md$') then
      local path = dir .. '/' .. name
      local stat = vim.uv.fs_stat(path)
      local heading = read_heading(path)
      items[#items + 1] = {
        file = path,
        name = name,
        mtime = stat and stat.mtime.sec or 0,
        label = (heading and heading ~= '') and heading or name:gsub('%.md$', ''),
      }
    end
  end
  table.sort(items, function(a, b)
    return a.mtime > b.mtime
  end)
  return items
end

-- <leader>nl: open the most recently modified scratch.
function M.last()
  local items = M.list()
  if #items == 0 then
    notify('No scratch notes yet', vim.log.levels.WARN)
    return
  end
  M.open(items[1].file, 'Opened')
end

-- <leader>nf: Snacks picker over scratch notes, newest first, H1 as label.
function M.pick()
  local pickers = require('shamindras.plugins.snacks.pickers')
  local items = M.list()
  if #items == 0 then
    notify('No scratch notes yet', vim.log.levels.WARN)
    return
  end
  for idx, item in ipairs(items) do
    item.idx = idx
    item.text = item.label .. ' ' .. item.name
  end

  Snacks.picker({
    title = 'Scratch',
    items = items,
    format = function(item)
      return {
        { item.label },
        { '  ' .. relative_age(item.mtime), 'SnacksPickerComment' },
      }
    end,
    -- idx is already mtime order; score only matters once a query is typed
    sort = { fields = { 'score:desc', 'idx' } },
    layout = 'ivy',
    layouts = { ivy = pickers.ivy_layout },
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.schedule(function()
          M.open(item.file)
        end)
      end
    end,
  })
end

-- <leader>ng: ripgrep picker scoped to the scratch directory.
function M.grep()
  require('shamindras.plugins.snacks.pickers').grep_with_ripgrep({
    cwd = M.dir(),
    title = 'Scratch Grep',
  })
end

-- }}}

-- {{{ Rename / Delete / Promote

-- <leader>nr: rename the current scratch to the slug of its H1.
function M.rename_from_heading()
  if not guard() then
    return
  end
  local heading = first_heading(vim.api.nvim_buf_get_lines(0, 0, 5, false))
  if not heading or heading == '' then
    notify('No heading to rename from', vim.log.levels.WARN)
    return
  end
  local name = slug.slugify(heading)
  if name == '' then
    notify('Heading has no slug-able characters', vim.log.levels.WARN)
    return
  end

  local old_path = vim.api.nvim_buf_get_name(0)
  local new_path = M.dir() .. '/' .. name .. '.md'
  if realpath(old_path) == new_path then
    notify('Already named ' .. name .. '.md')
    return
  end
  if vim.uv.fs_stat(new_path) then
    notify('Scratch already exists: ' .. name .. '.md', vim.log.levels.ERROR)
    return
  end

  if vim.bo.modified then
    vim.cmd.write()
  end
  file.rename_to(old_path, new_path)
end

-- <leader>nd: delete the current scratch (confirm), then open the picker.
function M.delete_current()
  if not guard() then
    return
  end
  local path = vim.api.nvim_buf_get_name(0)
  local filename = vim.fn.fnamemodify(path, ':t')
  if vim.fn.confirm('Delete scratch ' .. filename .. '?', '&Yes\n&No', 2) ~= 1 then
    return
  end

  vim.fn.delete(path)
  Snacks.bufdelete({ force = true })
  notify('Deleted scratch: ' .. filename)
  if #M.list() > 0 then
    M.pick()
  end
end

-- <leader>np: create a zk idea from the H1 + body, then remove the scratch.
-- The idea template does not render {{content}}, so the body is appended
-- to the new note after zk creates it.
function M.promote_current()
  if not guard() then
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local heading = first_heading(lines)
  if not heading or heading == '' then
    notify('Add a heading before promoting', vim.log.levels.WARN)
    return
  end

  local notebook = vim.env.ZK_NOTEBOOK_DIR
  notebook = notebook and notebook ~= '' and vim.uv.fs_realpath(notebook)
  if not notebook then
    notify('zk: ZK_NOTEBOOK_DIR is not set or missing', vim.log.levels.ERROR)
    return
  end

  -- Body: everything after the heading line, leading blank lines dropped.
  local body = {}
  local past_heading = false
  for _, line in ipairs(lines) do
    if past_heading then
      if #body > 0 or line:match('%S') then
        body[#body + 1] = line
      end
    elseif line:match('^#%s+') then
      past_heading = true
    end
  end

  if vim.bo.modified then
    vim.cmd.write()
  end

  local old_path = vim.api.nvim_buf_get_name(0)
  local old_buf = vim.api.nvim_get_current_buf()
  local title = vim.trim(heading):lower()

  require('zk.api').new(nil, {
    dir = notebook .. '/ideas',
    title = title,
    extra = { display_title = slug.to_title(slug.slugify(title)) },
  }, function(err, res)
    if err then
      local msg = type(err) == 'table' and err.message or tostring(err)
      notify('Promote failed: ' .. msg, vim.log.levels.ERROR)
      return
    end
    if not (res and res.path) then
      notify('Promote failed: zk returned no path', vim.log.levels.ERROR)
      return
    end

    if #body > 0 then
      local fh = io.open(res.path, 'a')
      if fh then
        fh:write('\n' .. table.concat(body, '\n') .. '\n')
        fh:close()
      end
    end

    vim.fn.delete(old_path)
    vim.cmd('edit ' .. vim.fn.fnameescape(res.path))
    if vim.api.nvim_buf_is_valid(old_buf) then
      vim.api.nvim_buf_delete(old_buf, { force = true })
    end
    notify('Promoted to idea: ' .. vim.fn.fnamemodify(res.path, ':t'))
  end)
end

-- }}}

return M
