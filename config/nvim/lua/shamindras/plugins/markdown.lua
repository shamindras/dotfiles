return {
  'tadmccorkle/markdown.nvim',
  ft = 'markdown',
  opts = {
    mappings = {
      inline_surround_toggle = 'gl',
      inline_surround_toggle_line = 'gll',
      inline_surround_delete = 'ds',
      inline_surround_change = 'cs',
      link_add = false,
      link_follow = false,
      go_curr_heading = ']h',
      go_parent_heading = '[h',
      go_next_heading = ']]',
      go_prev_heading = '[[',
    },
    on_attach = function(bufnr)
      local map = vim.keymap.set
      local opts = function(desc)
        return { buffer = bufnr, desc = desc }
      end

      -- {{{ Link Operations -------------------------------------------------------------------

      map('n', '<CR>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts('Follow link'))
      map({ 'n', 'v' }, 'gL', '<Plug>(markdown_add_link)', opts('Add link'))

      -- ------------------------------------------------------------------------- }}}

      -- {{{ Quick Toggles (cursor word) -------------------------------------------------------

      -- Bold: toggle ** around cursor word
      map({ 'n', 'v', 'i' }, '<C-b>', function()
        if vim.fn.mode() == 'i' then
          vim.cmd('stopinsert')
        end
        vim.cmd('normal gliwb')
      end, opts('Toggle bold'))

      -- Italic: toggle * around cursor word
      map({ 'n', 'v', 'i' }, '<C-t>', function()
        if vim.fn.mode() == 'i' then
          vim.cmd('stopinsert')
        end
        vim.cmd('normal gliwi')
      end, opts('Toggle italic'))

      -- ------------------------------------------------------------------------- }}}

      -- {{{ Markdown Commands -----------------------------------------------------------------

      map('n', '<leader>mx', '<Cmd>MDTaskToggle<CR>', opts('[m]arkdown checkbox toggle [x]'))
      map('x', '<leader>mx', ':MDTaskToggle<CR>', opts('[m]arkdown checkbox toggle [x]'))
      map('n', '<leader>mo', '<Cmd>MDListItemBelow<CR>', opts('[m]arkdown list item below [o]'))
      map('n', '<leader>mO', '<Cmd>MDListItemAbove<CR>', opts('[m]arkdown list item above [O]'))
      map('n', '<leader>mt', '<Cmd>MDInsertToc<CR>', opts('[m]arkdown insert [t]oc'))
      map('n', '<leader>mT', '<Cmd>MDToc<CR>', opts('[m]arkdown [T]oc (loclist)'))

      -- ------------------------------------------------------------------------- }}}

      -- {{{ Render Toggle ---------------------------------------------------------------------

      map('n', '<leader>mR', '<Cmd>RenderMarkdown toggle<CR>', opts('[m]arkdown [R]ender toggle'))

      -- ------------------------------------------------------------------------- }}}
    end,
  },
}
