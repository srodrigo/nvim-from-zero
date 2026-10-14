local map = vim.keymap.set

-- [[ Leader Key ]] --

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Completion ]] --

vim.opt.completeopt = { "menuone", "noselect", "popup" }

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
