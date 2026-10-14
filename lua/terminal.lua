local terminal_buf
local terminal_win
local terminal_layout

local function live_terminal()
	return terminal_buf
	    and vim.api.nvim_buf_is_valid(terminal_buf)
	    and vim.bo[terminal_buf].buftype == 'terminal'
	    and vim.fn.jobwait({ vim.b[terminal_buf].terminal_job_id }, 0)[1] == -1
end

local function terminal_window_open()
	return terminal_win
	    and vim.api.nvim_win_is_valid(terminal_win)
	    and vim.api.nvim_win_get_buf(terminal_win) == terminal_buf
end

local function hide_terminal()
	if #vim.api.nvim_tabpage_list_wins(0) == 1 and vim.api.nvim_get_current_win() == terminal_win then
		vim.cmd('hide enew')
	else
		vim.api.nvim_win_hide(terminal_win)
	end
	terminal_win = nil
end

local function open_terminal(layout)
	if terminal_window_open() then
		vim.api.nvim_set_current_win(terminal_win)
	else
		local reuse = live_terminal()
		if layout == 'float' then
			local width = math.max(1, math.floor(vim.o.columns * 0.95))
			local height = math.max(1, math.floor(vim.o.lines * 0.95))
			local buf = reuse and terminal_buf or vim.api.nvim_create_buf(false, true)
			terminal_win = vim.api.nvim_open_win(buf, true, {
				relative = 'editor',
				width = width,
				height = height,
				row = math.floor((vim.o.lines - height) / 2),
				col = math.floor((vim.o.columns - width) / 2),
				style = 'minimal',
				border = 'rounded',
			})
			if not reuse then
				vim.fn.jobstart(vim.o.shell, { term = true })
				terminal_buf = buf
			end
		else
			vim.cmd(layout == 'vertical' and 'botright vsplit' or 'botright split')
			terminal_win = vim.api.nvim_get_current_win()
			if reuse then
				vim.api.nvim_win_set_buf(terminal_win, terminal_buf)
			else
				vim.cmd('terminal')
				terminal_buf = vim.api.nvim_get_current_buf()
			end
		end
		terminal_layout = layout
	end

	-- vim.cmd('startinsert')
end

local function toggle_terminal(layout)
	if terminal_window_open() then
		if terminal_layout ~= layout then
			hide_terminal()
		elseif vim.api.nvim_get_current_win() == terminal_win then
			hide_terminal()
			return
		end
	end

	open_terminal(layout)
end

vim.api.nvim_create_autocmd('TermOpen', {
	group = vim.api.nvim_create_augroup('TerminalWindowOptions', { clear = true }),
	callback = function(args)
		vim.api.nvim_set_option_value('number', false, { win = vim.api.nvim_get_current_win() })
		vim.api.nvim_set_option_value('relativenumber', false, { win = vim.api.nvim_get_current_win() })
		vim.api.nvim_set_option_value('signcolumn', 'no', { win = vim.api.nvim_get_current_win() })
		vim.bo[args.buf].buflisted = false
	end,
})

vim.api.nvim_create_user_command('TermToggle', function()
	toggle_terminal(terminal_layout or 'horizontal')
end, { desc = 'Toggle the most recently used terminal layout' })

vim.api.nvim_create_user_command('TermToggleVertical', function()
	toggle_terminal('vertical')
end, { desc = 'Toggle terminal in a vertical split' })

vim.api.nvim_create_user_command('TermToggleHorizontal', function()
	toggle_terminal('horizontal')
end, { desc = 'Toggle terminal in a horizontal split' })

vim.api.nvim_create_user_command('TermToggleFloat', function()
	toggle_terminal('float')
end, { desc = 'Toggle terminal in a floating window' })
