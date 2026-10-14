local M = {}

local modes = {
	n = 'NORMAL',
	i = 'INSERT',
	v = 'VISUAL',
	V = 'VISUAL LINE',
	['\22'] = 'VISUAL BLOCK',
	R = 'REPLACE',
	c = 'COMMAND',
	t = 'TERMINAL',
	s = 'SELECT',
	S = 'SELECT LINE',
	['\19'] = 'SELECT BLOCK',
}

function M.mode()
	local mode = vim.fn.mode()
	return modes[mode] or modes[mode:sub(1, 1)] or mode:upper()
end

function M.left()
	local branch = vim.fn.FugitiveHead()
	if branch == '' then
		return M.mode()
	end
	return M.mode() .. ' | ' .. branch
end

vim.o.statusline = " %{v:lua.require'statusline'.left()} | %f%= %y %p%% | %l:%c "

local tree_statusline = ' %{getcwd()} '

vim.api.nvim_create_autocmd('BufWinEnter', {
	callback = function(event)
		if vim.bo[event.buf].filetype == 'NvimTree' then
			vim.wo.statusline = tree_statusline
		elseif vim.wo.statusline == tree_statusline then
			vim.wo.statusline = ''
		end
	end,
})

return M
