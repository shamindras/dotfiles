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
    -- Enable auto-installation of formatters
    auto_install = true,

    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_format' },
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      zsh = { 'shfmt' },
      make = { 'make-format' },
      json = { 'jq' },
      toml = { 'taplo' },
      yaml = { 'yq' },
      ['*'] = { 'trim_whitespace' }, -- Default trim-whitespace for all other filetypes
    },

    -- Formatter-specific settings
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
      yq = {
        -- YAML formatter: Use 2 spaces for indentation and preserve key order
        prepend_args = { '--indent', '2', '--no-sort-keys' },
        condition = function(ctx)
          -- Ensure the file is readable
          return vim.fn.filereadable(ctx.filename) == 1
        end,
      },
      ruff_format = {
        -- Python formatter settings
        condition = function(ctx)
          return vim.fs.find({ 'pyproject.toml', 'ruff.toml' }, { path = ctx.filename, upward = true })[1] ~= nil
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
      make_format = {
        command = 'make',
        args = { '--help' },
        stdin = false,
        cwd = function()
          return vim.fn.getcwd()
        end,
      },
    },

    -- Format on save with optimizations
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
  },
}
