-- {{{ Project-local resolver
--
-- Local-first, global-fallback resolution for the **subset** of language
-- tools that benefit from per-project version pinning (e.g., a uv-managed
-- Python project's `<root>/.venv/bin/ruff` should win over Mason's global
-- ruff). This is NOT a registry of every nvim-managed tool — most tools
-- (lua_ls, marksman, stylua, jq, yq, prettier, etc.) have no project-local
-- install convention and resolve via Mason's PATH prepend without needing
-- this helper. Only register a tool here if it has a real `<project>/<bin>/`
-- pinning pattern (e.g., Python `.venv/bin`, Node `node_modules/.bin`).
--
-- A registered tool always belongs to one language; the helper looks up
-- the language, walks up from an anchor (buffer dir or explicit cwd) to
-- find the project root, and returns <root>/<bin_dir>/<tool> if it exists.
-- Falls through to Mason → PATH → bare name otherwise.
--
-- Adding a new local-first tool = one row in `local_first_tools`.
-- Adding a new language profile = one row in `language_profiles`.
-- No code changes required for either.
--
-- Caching: keyed by (tool, root_dir). Never invalidated within a session.
-- Recovery from a stale cache (e.g. .venv created mid-session) is
-- `:LspRestart` or restarting nvim.

local M = {}

-- {{{ Registries

-- Tools that benefit from per-project version pinning. Each entry maps to
-- exactly one language profile (which describes how to find the project
-- root and where its project-local binaries live). Tools NOT listed here
-- are not local-first — they resolve globally via Mason's PATH prepend.
local local_first_tools = {
  ruff = 'python',
  ty = 'python',
}

-- Each language describes how to find its project root and where its
-- project-local binaries live.
local language_profiles = {
  python = {
    root_markers = { 'pyproject.toml', 'uv.lock', '.venv' },
    bin_dir = '.venv/bin',
  },
}

-- }}}

-- {{{ Cache

-- cache[tool][root_dir] = absolute path string
local cache = {}

local function cache_get(tool, root)
  return cache[tool] and cache[tool][root]
end

local function cache_set(tool, root, path)
  cache[tool] = cache[tool] or {}
  cache[tool][root] = path
end

-- }}}

-- {{{ Resolution

local function fallback(tool)
  local global = vim.fn.exepath(tool)
  return global ~= '' and global or tool
end

--- Compute an upward-search anchor from caller-provided opts.
--- Precedence: opts.cwd > opts.bufnr's filename > current buffer's filename > cwd.
local function resolve_anchor(opts)
  if opts.cwd then
    return opts.cwd
  end
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= '' then
    return name
  end
  return vim.fn.getcwd()
end

--- Find the project root for a language by walking up from an anchor.
--- The single source of truth for "what counts as a project" per language.
--- Use this anywhere you need to gate behavior on project membership
--- (e.g. conform/nvim-lint conditions) so callers cannot drift from the
--- helper's root_markers.
--- @param language string Must be registered in language_profiles
--- @param anchor? string File path or directory to walk up from
---                       (default: current buffer's filename, or cwd)
--- @return string|nil Absolute path to project root, or nil if no marker found
function M.find_root(language, anchor)
  local profile = language_profiles[language]
  if not profile then
    return nil
  end
  if not anchor or anchor == '' then
    anchor = resolve_anchor({})
  end
  return vim.fs.root(anchor, profile.root_markers)
end

--- Resolve a tool to an absolute binary path.
--- @param tool string Tool name (must be registered in `local_first_tools`)
--- @param opts? table
---   bufnr (integer): resolve relative to this buffer's directory
---                    (default: current buffer)
---   cwd   (string):  resolve relative to this directory instead
---                    (overrides bufnr; used by LSP startup)
--- @return string Absolute path. Falls back to bare tool name if no global on PATH.
function M.resolve_tool(tool, opts)
  opts = opts or {}

  local lang = local_first_tools[tool]
  if not lang then
    vim.notify(('project_local_resolver: unknown tool %q (add to local_first_tools)'):format(tool), vim.log.levels.WARN)
    return fallback(tool)
  end

  local profile = language_profiles[lang]
  if not profile then
    return fallback(tool)
  end

  local anchor = resolve_anchor(opts)
  local root = M.find_root(lang, anchor)

  if root then
    local cached = cache_get(tool, root)
    if cached then
      return cached
    end

    local local_path = root .. '/' .. profile.bin_dir .. '/' .. tool
    if vim.fn.executable(local_path) == 1 then
      cache_set(tool, root, local_path)
      return local_path
    end
  end

  -- Global fallback chain: Mason bin dir -> PATH -> bare tool name.
  -- Mason is the canonical global fallback for nvim-only tools per the
  -- repo principle ("Mason owns the global fallback for nvim-only tools;
  -- Homebrew for shell-shared tools"). Checking it explicitly here makes
  -- the helper work regardless of plugin load order (some plugins prepend
  -- mason bin to PATH lazily, which is too late for LSP cmd resolution at
  -- lspconfig load time).
  local key = root or '__global__'
  local cached = cache_get(tool, key)
  if cached then
    return cached
  end

  local mason_path = vim.fn.stdpath('data') .. '/mason/bin/' .. tool
  if vim.fn.executable(mason_path) == 1 then
    cache_set(tool, key, mason_path)
    return mason_path
  end

  local resolved = fallback(tool)
  cache_set(tool, key, resolved)
  return resolved
end

-- }}}

return M
-- }}}
