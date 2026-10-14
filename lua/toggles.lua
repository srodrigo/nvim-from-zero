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

return M
