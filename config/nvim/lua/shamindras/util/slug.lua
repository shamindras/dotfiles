-- slug.lua — shared title <-> slug helpers (zk ideas, scratch notes)
--
-- Slug rule: lowercase, runs of non-alphanumerics to '-', strip leading
-- and trailing '-'. Keep in step with the shell twin in
-- config/bin/scratch-new (documented once in config/zsh/CLAUDE.md).

local M = {}

-- {{{ Slugify

-- "API Design!" → "api-design"; "" / "!!!" → ""
---@param title string
---@return string
function M.slugify(title)
  local s = vim.trim(title or ''):lower()
  s = s:gsub('[^%w]+', '-')
  s = s:gsub('^%-+', '')
  s = s:gsub('%-+$', '')
  return s
end

-- }}}

-- {{{ Title Case

-- "deep-learning" → "Deep Learning"
---@param slug string
---@return string
function M.to_title(slug)
  local with_spaces = slug:gsub('-', ' ')
  local title = with_spaces:gsub("(%a)([%w_']*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
  return title
end

-- }}}

return M
