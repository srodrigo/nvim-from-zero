vim.pack.add({
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/ibhagwan/fzf-lua' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/gbprod/nord.nvim' },
})

require('mason').setup()

-- The plugin installs the parser and queries; Neovim does the highlighting.
require('nvim-treesitter').install({ 'lua' }):wait(300000)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function(event)
    vim.treesitter.start(event.buf, 'lua')
  end,
})
