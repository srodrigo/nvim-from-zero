vim.pack.add({
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/stevearc/conform.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/ibhagwan/fzf-lua' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/gbprod/nord.nvim' },
})

require('mason').setup()

require('conform').setup({
  formatters_by_ft = {
    javascript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
  },
})

local prettier_filetypes = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}

vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function(event)
    if prettier_filetypes[vim.bo[event.buf].filetype] then
      require('conform').format({ bufnr = event.buf, timeout_ms = 1000 })
    end
  end,
})

-- The plugin installs the parser and queries; Neovim does the highlighting.
require('nvim-treesitter').install({ 'lua', 'typescript', 'tsx' }):wait(300000)
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'typescript', 'typescriptreact' },
  callback = function(event)
    local parser = event.match == 'typescriptreact' and 'tsx' or event.match
    vim.treesitter.start(event.buf, parser)
  end,
})
