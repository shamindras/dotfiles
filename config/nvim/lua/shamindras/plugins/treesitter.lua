return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false, -- Ensure it loads immediately
  },
  {
    'MeanderingProgrammer/treesitter-modules.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    lazy = false, -- Don't lazy load
    opts = {
      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = {
        'bash',
        'cmake',
        -- 'css',
        'dockerfile',
        'gitignore',
        'go',
        'html',
        'java',
        'javascript',
        'json',
        'lua',
        'make',
        'markdown',
        'markdown_inline',
        'python',
        'regex',
        'sql',
        -- 'terraform',
        'toml',
        -- 'tsx',
        -- 'typescript',
        'vim',
        'vimdoc',
        'yaml',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<Enter>',
          node_incremental = '<Enter>',
          scope_incremental = false,
          node_decremental = '<BS>',
        },
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
