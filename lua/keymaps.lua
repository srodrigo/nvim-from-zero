local map = vim.keymap.set
local diagnostics = require('diagnostics')
local buffers = require('buffers')
local completion = require('completion')

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

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

map('n', '[d', diagnostics.previous, { desc = 'Go to Previous [d]iagnostic message' })
map('n', ']d', diagnostics.next, { desc = 'Go to Next [d]iagnostic message' })
map('n', '[e', diagnostics.previous_error, { desc = 'Go to Previous [e]rror message' })
map('n', ']e', diagnostics.next_error, { desc = 'Go to Next [e]rror message' })
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line [d]iagnostics' })
map('n', '<leader>cq', diagnostics.open_buffer_on_quickfix, { desc = 'Diagnostic [q]uickfix list' })

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
map("i", "<Tab>", completion.next, { expr = true, desc = "Next completion or snippet jump" })

-- Shift-Tab to navigate completion menu backwards
map("i", "<S-Tab>", completion.previous, { expr = true, desc = "Previous completion or snippet jump" })

-- [[ Buffers ]]

map('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
map('n', ']b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
map('n', '<leader>bd', '<cmd>:bp | sp | bn | bd<cr>', { desc = '[d]elete Buffer' })
map('n', '<leader>bo', buffers.delete_all_other_buffers, { desc = 'Delete All [o]ther Buffers', silent = true })

-- [[ Tabs ]]
map('n', '<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Close [o]ther Tabs' })
map('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = 'New Tab' })
map('n', '<leader><tab>d', '<cmd>tabclose<cr>', { desc = '[d]elete (Close) Tab' })
map('n', ']<tab>', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
map('n', '[<tab>', '<cmd>tabprevious<cr>', { desc = 'Previous Tab' })

-- [[ Terminal ]]

map('n', '<leader>tt', '<cmd>TermToggle<cr>', { desc = 'Toggle terminal' })
map('n', '<leader>th', '<cmd>TermToggleHorizontal<cr>', { desc = 'Toggle horizontal terminal' })
map('n', '<leader>tv', '<cmd>TermToggleVertical<cr>', { desc = 'Toggle vertical terminal' })
map('n', '<leader>tf', '<cmd>TermToggleFloat<cr>', { desc = 'Toggle floating terminal' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- [[ Git ]]

map('n', '<leader>gd', '<cmd>:tab Git<cr>', { desc = 'Open [d]iff View' })
map('n', '<leader>gm', "<cmd>:exec 'norm O' | Gvdiffsplit!<cr>", { desc = 'Open [m]erge View' })
map('n', '<leader>gl', '<cmd>:0GcLog<cr>', { desc = 'Open file [l]og' })
