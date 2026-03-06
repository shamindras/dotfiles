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
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby', 'markdown' },
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
