vim.pack.add({
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/stevearc/conform.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/windwp/nvim-ts-autotag' },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/ibhagwan/fzf-lua' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://forge.barrettruth.com/barrettruth/diffs.nvim' },
  { src = 'https://github.com/gbprod/nord.nvim' },
  { src = 'https://github.com/OXY2DEV/markview.nvim' },
})

require('mason').setup()

local prettier_filetypes = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  markdown = true,
}

require('conform').setup({
  formatters_by_ft = {
    fennel = { 'fnlfmt' },
    javascript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
  },
  format_on_save = function(bufnr)
    if vim.bo[bufnr].filetype == 'fennel' and vim.g.format_on_save then
      return { bufnr = bufnr, timeout_ms = 1000 }
    end
  end,
  -- Async formatting to avoid prettier blocking save on large codebases
  format_after_save = function(bufnr)
    if vim.bo[bufnr].filetype == 'fennel' then
      return
    end
    if not vim.g.format_on_save and not prettier_filetypes[vim.bo[bufnr].filetype] then
      return
    end
	return { bufnr = bufnr }
  end,
})

-- The plugin installs the parser and queries; Neovim does the highlighting.
require('nvim-treesitter').install({ 'lua', 'fennel', 'html', 'typescript', 'tsx', 'markdown', 'markdown_inline', 'diff' }):wait(300000)
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'fennel', 'html', 'typescript', 'typescriptreact' },
  callback = function(event)
    local parser = event.match == 'typescriptreact' and 'tsx' or event.match
    vim.treesitter.start(event.buf, parser)
  end,
})

require('nvim-ts-autotag').setup()
