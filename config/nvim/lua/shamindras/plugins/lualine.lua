return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    { 'lewis6991/gitsigns.nvim' },
  },
  enabled = true,
  event = { 'VeryLazy' },
  opts = function()
    -- TODO: use mini.icons instead
    local icons = {
      diagnostics = {
        error = '\u{2718}', -- ?
        warn = '\u{26A0}', -- ?
        info = '\u{2139}', -- ?
        hint = '\u{2691}', -- ?
      },
      git = {
        added = '\u{271A}', -- ?
        modified = '\u{2739}', -- ?
        removed = '\u{2716}', -- ?
        renamed = '\u{279C}', -- ?
        untracked = '\u{2605}', -- ?
      },
    }

    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn', 'info', 'hint' },
      symbols = {
        error = icons.diagnostics.error,
        warn = icons.diagnostics.warn,
        info = icons.diagnostics.info,
        hint = icons.diagnostics.hint,
      },
      colored = true,
      update_in_insert = false,
      always_visible = false,
    }

    local diff = {
      'diff',
      symbols = {
        added = icons.git.added,
        modified = icons.git.modified,
        removed = icons.git.removed,
        renamed = icons.git.renamed,
        untracked = icons.git.untracked,
      },
      colored = true,
      always_visible = false,
      source = function()
        local gitsigns = vim.b.gitsigns_status_dict
        if gitsigns then
          return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
          }
        end
      end,
    }

    local filename = {
      'filename',
      file_status = true,
      newfile_status = false,
      path = 1,
      symbols = {
        modified = '[+]',
        readonly = '\u{1F512}', -- ??
        unnamed = '[No Name]',
        newfile = '[New]',
      },
    }

    return {
      options = {
        theme = 'auto',
        globalstatus = true,
        disabled_filetypes = { statusline = { 'dashboard', 'lazy', 'alpha' } },
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
        lualine_c = {
          filename,
          diff,
          diagnostics,
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { 'quickfix' },
    }
  end,
}
