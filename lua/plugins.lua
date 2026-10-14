vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
})

-- The plugin installs the parser and queries; Neovim does the highlighting.
require('nvim-treesitter').install({ 'lua' }):wait(300000)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function(event)
    vim.treesitter.start(event.buf, 'lua')
  end,
})
