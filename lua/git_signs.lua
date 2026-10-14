require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 400,
  },
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk('next')
      end
    end, { desc = 'Next git hunk' })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk('prev')
      end
    end, { desc = 'Previous git hunk' })

    map({ 'n', 'v' }, '<leader>gs', gitsigns.stage_hunk, { desc = 'Git stage hunk' })
    map({ 'n', 'v' }, '<leader>gr', gitsigns.reset_hunk, { desc = 'Git reset hunk' })
    map('n', '<leader>gS', gitsigns.stage_buffer, { desc = 'Git stage buffer' })
    map('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = 'Git undo stage hunk' })
    map('n', '<leader>gR', gitsigns.reset_buffer, { desc = 'Git reset buffer' })
    map('n', '<leader>gp', gitsigns.preview_hunk, { desc = 'Git preview hunk' })
    map('n', '<leader>gb', gitsigns.blame_line, { desc = 'Git blame line' })
    map({ 'o', 'x' }, 'ih', '<cmd>Gitsigns select_hunk<cr>', { desc = 'Select git hunk' })
  end,
}
