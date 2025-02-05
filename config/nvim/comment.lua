-- Easily comment visual regions/lines
return {
  'numToStr/Comment.nvim',
  event = { 'BufRead', 'InsertEnter' }, -- Load on BufRead (opening a file) or InsertEnter
  opts = {},
}
