local nordBackground = '#2D303C'
local nord3 = '#4c566a'

require('nord').setup({
  diff = { mode = 'fg' },
  on_highlights = function(highlights, _)
    highlights.Normal.bg = nordBackground
    highlights.DiffAdd.bg = 'NONE'
    highlights.DiffDelete.bg = 'NONE'
    highlights.NvimTreeIndentMarker.fg = nord3
  end,
})

vim.cmd.colorscheme 'nord'
