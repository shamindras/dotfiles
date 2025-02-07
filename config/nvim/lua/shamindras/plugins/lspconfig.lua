-- LSP Plugins
return {
  {
    'folke/lazydev.nvim',
    event = { 'BufReadPre', 'BufNewFile' }, -- Load when buffer is read or created
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  -- Remove the standalone luvit-meta plugin since it's causing issues
  -- We'll handle its functionality through lazydev

  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' }, -- Load when buffer is read or created
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
      {
        'j-hui/fidget.nvim',
        event = 'LspAttach',
        opts = {},
      },
      {
        'hrsh7th/cmp-nvim-lsp',
        event = 'InsertEnter', -- Load when entering insert mode
      },
    },
    config = function()
      -- Your existing LSP configuration code here
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- Your existing LSP attach code here
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities =
        vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        pylsp = {
          -- Your existing pylsp configuration
        },
        lua_ls = {
          -- Your existing lua_ls configuration
        },
        ruff = {
          -- Your existing lua_ls configuration
        },
      }

      -- Mason setup with explicit ensure_installed configuration
      require('mason').setup {
        ui = {
          icons = {
            package_installed = '✅',
            package_pending = '🟡',
            package_uninstalled = '❌',
          },
        },
      }

      -- Mason-lspconfig setup with explicit handlers
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities =
              vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      -- Mason-tool-installer setup
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
      })
      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
        auto_update = true,
        run_on_start = true,
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
