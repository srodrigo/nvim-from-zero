local M = {}

---@param buf? number
---@param value? boolean
function M.toggle_inlay_hints(buf, value)
	local ih = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
	if type(ih) == 'function' then
		ih(buf, value)
	elseif type(ih) == 'table' and ih.enable then
		if value == nil then
			value = not ih.is_enabled { bufnr = buf or 0 }
		end
		ih.enable(value, { bufnr = buf })

		if value then
			vim.notify 'Inlay Hints enabled'
		else
			vim.notify 'Inlay Hints disabled'
		end
	end
end

local diagnostics_enabled = true
function M.toggle_diagnostics()
	-- if this Neovim version supports checking if diagnostics are enabled
	-- then use that for the current state
	if vim.diagnostic.is_enabled then
		diagnostics_enabled = vim.diagnostic.is_enabled()
	elseif vim.diagnostic.is_disabled then
		diagnostics_enabled = not vim.diagnostic.is_disabled()
	end
	diagnostics_enabled = not diagnostics_enabled

	vim.diagnostic.enable(diagnostics_enabled)
	if diagnostics_enabled then
		vim.notify 'Diagnostics enabled'
	else
		vim.notify 'Diagnostics disabled'
	end
end

if vim.g.format_on_save == nil then
	vim.g.format_on_save = true
end
function M.toggle_format_on_save()
	vim.g.format_on_save = not vim.g.format_on_save

	if vim.g.format_on_save then
		vim.notify 'Format On Save enabled'
	else
		vim.notify 'Format On Save disabled'
	end
end

local zen

local function zen_size()
	local width = math.max(1, math.floor(vim.o.columns * 0.6))
	local height = math.max(1, vim.o.lines - vim.o.cmdheight - 1)
	return width, height
end

local function close_zen()
	if not zen then
		return
	end

	local current = zen
	zen = nil -- WinClosed also runs when we close these windows ourselves.

	if vim.api.nvim_win_is_valid(current.content) then
		local cursor = vim.api.nvim_win_get_cursor(current.content)
		if vim.api.nvim_win_is_valid(current.source) then
			pcall(vim.api.nvim_win_set_cursor, current.source, cursor)
		end
		vim.api.nvim_win_close(current.content, true)
	end
	if vim.api.nvim_win_is_valid(current.backdrop) then
		vim.api.nvim_win_close(current.backdrop, true)
	end
	if vim.api.nvim_win_is_valid(current.source) then
		vim.api.nvim_set_current_win(current.source)
	end
end

function M.toggle_zen()
	if zen then
		close_zen()
		return
	end
	local source = vim.api.nvim_get_current_win()
	local buffer = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(source)
	local width, height = zen_size()
	local backdrop_buffer = vim.api.nvim_create_buf(false, true)
	local backdrop = vim.api.nvim_open_win(backdrop_buffer, false, {
		relative = 'editor', row = 0, col = 0,
		width = vim.o.columns, height = height,
		style = 'minimal', focusable = false, zindex = 49,
	})
	vim.wo[backdrop].winhighlight = 'Normal:Normal,EndOfBuffer:Normal'
	vim.wo[backdrop].fillchars = 'eob: '

	local content = vim.api.nvim_open_win(buffer, true, {
		relative = 'editor', row = 0,
		col = math.floor((vim.o.columns - width) / 2),
		width = width, height = height,
		style = 'minimal', zindex = 50,
	})
	vim.api.nvim_win_set_cursor(content, cursor)
	zen = { source = source, backdrop = backdrop, content = content }
end

vim.api.nvim_create_autocmd('VimResized', {
	callback = function()
		if not zen then return end
		local width, height = zen_size()
		vim.api.nvim_win_set_config(zen.backdrop, {
			relative = 'editor', row = 0, col = 0,
			width = vim.o.columns, height = height,
		})
		vim.api.nvim_win_set_config(zen.content, {
			relative = 'editor', row = 0,
			col = math.floor((vim.o.columns - width) / 2),
			width = width, height = height,
		})
	end,
})

vim.api.nvim_create_autocmd('WinClosed', {
	callback = function(event)
		if zen and (tonumber(event.match) == zen.content or tonumber(event.match) == zen.backdrop) then
			local closed_zen = zen
			vim.schedule(function()
				if zen == closed_zen then close_zen() end
			end)
		end
	end,
})

vim.api.nvim_create_user_command('ZenToggle', M.toggle_zen, { desc = 'Toggle centered Zen mode' })

return M
