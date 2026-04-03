-- {{{ Plugin Specs

return {
  {
    'folke/lazydev.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      {
        'williamboman/mason.nvim',
        cmd = 'Mason',
        build = ':MasonUpdate',
        config = true,
      },
      {
        'williamboman/mason-lspconfig.nvim',
        cmd = { 'LspInstall', 'LspUninstall' },
      },
      {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        cmd = { 'MasonToolsInstall', 'MasonToolsUpdate' },
      },
    },
    config = function()
      -- {{{ LSP Attach Keymaps

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('LspAttachKeymaps', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buf = event.buf, desc = 'LSP: ' .. desc })
          end

          map('<leader>cd', vim.lsp.buf.definition, '[c]ode [d]efinition')
          map('<leader>cr', vim.lsp.buf.references, '[c]ode [r]eferences')
          map('<leader>ci', vim.lsp.buf.implementation, '[c]ode [i]mplementation')
          map('<leader>ca', vim.lsp.buf.code_action, '[c]ode [a]ctions')
          map('<leader>cn', vim.lsp.buf.rename, '[c]ode re[n]ame')
          map('<leader>ct', vim.lsp.buf.type_definition, '[c]ode [t]ype definition')
          map('<leader>cs', vim.lsp.buf.signature_help, '[c]ode [s]ignature help')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- highlight references to symbol under cursor on idle
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local hl_group = vim.api.nvim_create_augroup('lsp-document-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = hl_group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = hl_group,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- clean up document highlight autocmds when LSP detaches
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('LspDetachCleanup', { clear = true }),
        callback = function(event)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = 'lsp-document-highlight', buffer = event.buf })
        end,
      })

      -- }}}

      -- {{{ Server Definitions

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        pylsp = {},
        lua_ls = {},
        ruff = {},
        marksman = {
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            local zk_dir = vim.fn.getenv('ZK_NOTEBOOK_DIR')
            if zk_dir ~= vim.NIL and zk_dir ~= '' and vim.startswith(fname, zk_dir) then
              return -- skip zk notebooks → marksman won't attach
            end
            on_dir(require('lspconfig.util').root_pattern('.marksman.toml', '.git')(fname))
          end,
        },
      }

      -- }}}

      -- {{{ Mason Setup

      require('mason').setup({
        ui = {
          icons = {
            package_installed = '✅',
            package_pending = '🟡',
            package_uninstalled = '❌',
          },
        },
      })

      -- Servers managed outside Mason (installed via Homebrew)
      local mason_exclude = { 'marksman' }

      require('mason-lspconfig').setup({
        ensure_installed = vim.tbl_filter(function(s)
          return not vim.tbl_contains(mason_exclude, s)
        end, vim.tbl_keys(servers)),
        automatic_installation = { exclude = mason_exclude },
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            vim.lsp.config(server_name, server)
            vim.lsp.enable(server_name)
          end,
        },
      })

      -- Setup Homebrew-managed servers directly (not via mason-lspconfig handler)
      for _, server_name in ipairs(mason_exclude) do
        local server = servers[server_name] or {}
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config(server_name, server)
        vim.lsp.enable(server_name)
      end

      -- Mason-tool-installer setup
      local ensure_installed = vim.tbl_filter(function(s)
        return not vim.tbl_contains(mason_exclude, s)
      end, vim.tbl_keys(servers or {}))
      vim.list_extend(ensure_installed, {
        'stylua',
      })
      require('mason-tool-installer').setup({
        ensure_installed = ensure_installed,
        auto_update = true,
        run_on_start = true,
      })

      -- }}}
    end,
  },
}

-- }}}
