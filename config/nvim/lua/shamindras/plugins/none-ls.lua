-- Format on save and linters
return {
  'nvimtools/none-ls.nvim',
  event = { 'BufReadPre', 'BufNewFile' }, -- Load when reading or creating files
  dependencies = {
    {
      'nvimtools/none-ls-extras.nvim',
      lazy = true, -- Load only when explicitly required
    },
    {
      'jayp0521/mason-null-ls.nvim',
      cmd = { 'NullLsInstall', 'NullLsUninstall' }, -- Load only when these commands are used
    },
  },
  config = function()
    -- Lazy load the modules only when needed
    local null_ls = require 'null-ls'

    -- Create formatters and linters tables for lazy loading
    local formatting = setmetatable({}, {
      __index = function(_, key)
        return null_ls.builtins.formatting[key]
      end,
    })

    local diagnostics = setmetatable({}, {
      __index = function(_, key)
        return null_ls.builtins.diagnostics[key]
      end,
    })

    -- Configure mason-null-ls with specific conditions
    local mason_null_ls = require 'mason-null-ls'
    mason_null_ls.setup {
      ensure_installed = {
        'checkmake',
        'prettier',
        'stylua',
        'eslint_d',
        'shfmt',
        'ruff',
      },
      automatic_installation = true,
      handlers = {
        -- Add handlers for specific formatters/linters if needed
        function(source_name, methods)
          -- Automatic setup of mason installed tools
          mason_null_ls.default_setup(source_name, methods)
        end,
      },
    }

    -- Define sources with lazy loading considerations
    local sources = {
      diagnostics.checkmake,
      formatting.prettier.with {
        filetypes = { 'html', 'json', 'yaml', 'markdown' },
        -- Load prettier only for specific file types
        condition = function(utils)
          return utils.root_has_file {
            '.prettierrc',
            '.prettierrc.json',
            '.prettierrc.yml',
            '.prettierrc.js',
            'prettier.config.js',
          }
        end,
      },
      formatting.stylua.with {
        -- Load stylua only for Lua files with config
        condition = function(utils)
          return utils.root_has_file { 'stylua.toml', '.stylua.toml' }
        end,
      },
      formatting.shfmt.with {
        args = { '-i', '4' },
        -- Load shfmt only for shell files
        filetypes = { 'sh', 'bash', 'zsh' },
      },
      formatting.terraform_fmt.with {
        -- Load terraform formatter only for tf files
        filetypes = { 'terraform', 'tf', 'hcl' },
      },
      require('none-ls.formatting.ruff').with {
        extra_args = { '--extend-select', 'I' },
        -- Load ruff only for Python files
        filetypes = { 'python' },
      },
      require('none-ls.formatting.ruff_format').with {
        -- Load ruff_format only for Python files
        filetypes = { 'python' },
      },
    }

    -- Create format augroup with optimizations
    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

    -- Setup with performance optimizations
    null_ls.setup {
      -- debug = false, -- Disable debug mode by default for performance
      sources = sources,
      -- Debounce formatting for better performance
      should_attach = function(bufnr)
        -- Add conditions to determine if none-ls should attach
        local file_type = vim.api.nvim_buf_get_option(bufnr, 'filetype')
        local file_size = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        -- Don't attach to large files or binary files
        return file_size
            and #file_size < 100000
            and not vim.tbl_contains({ 'binary', 'help' }, file_type)
      end,
      on_attach = function(client, bufnr)
        if client.supports_method 'textDocument/formatting' then
          vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              -- Debounce formatting
              local timer = vim.loop.new_timer()
              timer:start(
                100,
                0,
                vim.schedule_wrap(function()
                  vim.lsp.buf.format {
                    async = false,
                    timeout_ms = 2000, -- Set reasonable timeout
                  }
                  timer:close()
                end)
              )
            end,
          })
        end
      end,
    }
  end,
}
