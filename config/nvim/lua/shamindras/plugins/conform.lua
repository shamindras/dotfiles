-- {{{ Formatter Mapping

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>bf',
      function()
        require('conform').format({ async = true, lsp_fallback = true })
      end,
      mode = '',
      desc = 'Format buffer',
    },
  },
  opts = {
    auto_install = true,

    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_format' },
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      -- zsh = { 'shfmt' },
      markdown = { 'prettier' },
      json = { 'jq' },
      toml = { 'taplo' },
      yaml = { 'yq' },
      ['*'] = { 'trim_whitespace' },
    },

    -- }}}

    -- {{{ Formatter Options

    formatters = {
      jq = {
        -- jq-specific arguments for JSON
        prepend_args = {
          '--indent',
          '2', -- 2 spaces indentation
        },
      },
      taplo = {
        -- TOML formatter: Use the `.taplo.toml` file if it exists
        condition = function(ctx)
          -- Recursive search for `.taplo.toml` in parent directories
          return vim.fs.find({ '.taplo.toml' }, { path = ctx.filename, upward = true })[1] ~= nil
        end,
      },
      -- yq: conform's built-in spec (`yq -P -`) is sufficient. mikefarah yq
      -- preserves key order and uses 2-space indent by default.
      ruff_format = {
        -- Local-first ruff: project's .venv/bin/ruff if available, global otherwise.
        -- See `lua/shamindras/util/project_local_resolver.lua` for the registry.
        command = function(_self, ctx)
          return require('shamindras.util.project_local_resolver').resolve_tool('ruff', { bufnr = ctx.buf })
        end,
        -- Only format files inside a Python project. Single source of truth
        -- for "what counts as a Python project" lives in project_local_resolver.lua.
        condition = function(ctx)
          return require('shamindras.util.project_local_resolver').find_root('python', ctx.filename) ~= nil
        end,
      },
      stylua = {
        -- Lua formatter specific options
        condition = function(ctx)
          return vim.fs.find({ 'stylua.toml', '.stylua.toml' }, { path = ctx.filename, upward = true })[1] ~= nil
        end,
      },
      shfmt = {
        -- Shell formatter options
        prepend_args = { '-i', '2' },
      },
    },

    -- }}}

    -- {{{ Format on Save

    format_on_save = function(bufnr)
      local file_size = #vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local file_type = vim.bo[bufnr].filetype

      -- Skip formatting for very large files or excluded types
      if file_size >= 100000 or vim.tbl_contains({ 'binary', 'help' }, file_type) then
        return
      end

      -- Apply format if the conditions are met
      return {
        timeout_ms = 2000,
        lsp_fallback = true,
      }
    end,

    -- }}}
  },
}
