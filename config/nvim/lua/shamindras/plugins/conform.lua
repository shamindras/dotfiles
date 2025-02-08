-- File: lua/shamindras/plugins/conform.lua
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>bf',
      function()
        require('conform').format { async = true, lsp_fallback = true }
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
      terraform = { 'terraform_fmt' },
      tf = { 'terraform_fmt' },
      hcl = { 'terraform_fmt' },
      make = { 'make-format' },
      ['*'] = { 'trim_whitespace' },
    },

    -- Formatter-specific settings
    formatters = {
      shfmt = {
        prepend_args = { '-i', '4' },
      },
      prettier = {
        -- Only run if config file is present
        condition = function(ctx)
          return vim.fs.find({
            '.prettierrc',
            '.prettierrc.json',
            '.prettierrc.yml',
            '.prettierrc.js',
            'prettier.config.js',
          }, { path = ctx.filename, upward = true })[1] ~= nil
        end,
      },
      stylua = {
        -- Only run if config file is present
        condition = function(ctx)
          return vim.fs.find({ 'stylua.toml', '.stylua.toml' }, {
            path = ctx.filename,
            upward = true,
          })[1] ~= nil
        end,
      },
      ['make-format'] = {
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
      -- Don't format large files
      local file_size = #vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local file_type = vim.bo[bufnr].filetype

      if file_size >= 100000 or vim.tbl_contains({ 'binary', 'help' }, file_type) then
        return
      end

      return {
        timeout_ms = 2000,
        lsp_fallback = true,
      }
    end,
  },
}
