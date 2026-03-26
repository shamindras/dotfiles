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
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('<leader>gd', vim.lsp.buf.definition, 'Go to Definition')
          -- Optional: Add these complementary navigation mappings
          map('<leader>gr', vim.lsp.buf.references, 'Go to References')
          map('<leader>gI', vim.lsp.buf.implementation, 'Go to Implementation')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

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

      -- Mason setup with explicit ensure_installed configuration
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

      -- Mason-lspconfig setup with explicit handlers
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
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
