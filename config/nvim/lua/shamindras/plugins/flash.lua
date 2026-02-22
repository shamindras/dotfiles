return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    modes = {
      search = {
        enabled = true,
      },
      char = {
        jump_labels = true,
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
  },
}
