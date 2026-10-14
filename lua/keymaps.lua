local map = vim.keymap.set

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Clear search with <esc>
map({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', { desc = 'Escape and Clear hlsearch' })

-- Quickfix
map('n', '[q', vim.cmd.cprev, { desc = 'Previous Quickfix' })
map('n', ']q', vim.cmd.cnext, { desc = 'Next Quickfix' })

map('n', '<leader>w', '<cmd>wall<cr>', { desc = '[w]rite all' })

-- Back to Normal mode
map('i', 'jk', '<esc>')

-- Better indenting
map('v', '<', '<gv')
map('v', '>', '>gv')

-- [[ Diagnostics ]]
local function open_buffer_diagnostics_on_quickfix()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.diagnostic.setqflist {
    title = 'Buffer diagnostics',
    format = function(diagnostic)
      if diagnostic.bufnr == bufnr then
        return diagnostic.message
      end
    end,
  }
end

-- local function open_buffer_diagnostics_on_quickfix()
--   local qflist = {}
--
--   local diagnostics = vim.diagnostic.get()
--   for _, diag in ipairs(diagnostics) do
--     if vim.fn.bufnr '%' == diag.bufnr then
--       table.insert(qflist, {
--         bufnr = diag.bufnr,
--         lnum = diag.lnum + 1,
--         col = diag.col + 1,
--         text = diag.message,
--         severity = diag.severity,
--       })
--     end
--   end
--
--   vim.fn.setqflist(qflist, 'r')
--   vim.cmd.copen()
-- end

map('n', '[d', function()
  vim.diagnostic.jump { count = -1 }
end, { desc = 'Go to Previous [d]iagnostic message' })
map('n', ']d', function()
  vim.diagnostic.jump { count = 1 }
end, { desc = 'Go to Next [d]iagnostic message' })
map('n', '[e', function()
  vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Go to Previous [e]rror message' })
map('n', ']e', function()
  vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Go to Next [e]rror message' })
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line [d]iagnostics' })
map('n', '<leader>cq', open_buffer_diagnostics_on_quickfix, { desc = 'Diagnostic [q]uickfix list' })

-- [[ Windows ]]

-- TIP: Disable arrow keys in normal mode
-- map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
map('n', '<C-w>m', '<C-w>|<C-w>_', { desc = 'Maximise Window' })

-- Resize window using <ctrl> arrow keys
map('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
map('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })
-- Resize window using <M> arrow keys
map('n', '<M-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
map('n', '<M-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
map('n', '<M-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
map('n', '<M-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- Tab to navigate completion menu or insert tab
map("i", "<Tab>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-n>"
	elseif vim.snippet.active({ direction = 1 }) then
		return "<Cmd>lua vim.snippet.jump(1)<CR>"
	else
		return "<Tab>"
	end
end, { expr = true, desc = "Next completion or snippet jump" })

-- Shift-Tab to navigate completion menu backwards
map("i", "<S-Tab>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-p>"
	elseif vim.snippet.active({ direction = -1 }) then
		return "<Cmd>lua vim.snippet.jump(-1)<CR>"
	else
		return "<S-Tab>"
	end
end, { expr = true, desc = "Previous completion or snippet jump" })
