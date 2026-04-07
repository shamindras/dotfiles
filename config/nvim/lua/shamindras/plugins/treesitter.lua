-- {{{ Treesitter Configuration

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
  },
  {
    'MeanderingProgrammer/treesitter-modules.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = 'VeryLazy',
    opts = {
      -- nvim 0.11+ bundles: c, lua, markdown, markdown_inline, query, vim, vimdoc
      -- Only list NON-bundled parsers below. Pre-installed by
      -- scripts/setup-nvim-treesitter to prevent races on concurrent nvim starts.
      ensure_installed = {
        'bash',
        'gitignore',
        'javascript',
        'json',
        'just',
        'python',
        'tmux',
        'toml',
        'yaml',
        'zsh',
      },
      auto_install = false, -- races when multiple nvim instances start
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}

-- }}}
