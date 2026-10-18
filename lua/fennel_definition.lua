local M = {}

local function symbol_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  for start, symbol in line:gmatch('()([%a_][%w_%.]*)') do
    if col >= start - 1 and col < start - 1 + #symbol then
      return symbol
    end
  end
end

local function love_library()
  local executable = vim.uv.fs_realpath(vim.fn.exepath('lua-language-server'))
  if not executable then
    return
  end

  local bin_dir = vim.fs.dirname(executable)
  for _, parent in ipairs({
    bin_dir,
    vim.fs.joinpath(bin_dir, 'libexec'),
    vim.fs.dirname(bin_dir),
    vim.fs.joinpath(vim.fs.dirname(bin_dir), 'libexec'),
  }) do
    local library = vim.fs.joinpath(parent, 'meta', '3rd', 'love2d', 'library')
    if vim.uv.fs_stat(vim.fs.joinpath(library, 'love.lua')) then
      return library
    end
  end
end

function M.go_to_love_metadata()
  local symbol = symbol_at_cursor()
  if not symbol or not symbol:match('^love%.[%w_%.]+$') then
    return false
  end

  local library = love_library()
  if not library then
    return false
  end

  local module = symbol:match('^love%.([%w_]+)%.')
  local path = module and vim.fs.joinpath(library, 'love', module .. '.lua') or vim.fs.joinpath(library, 'love.lua')
  if not vim.uv.fs_stat(path) then
    return false
  end

  local needle = 'function ' .. symbol .. '('
  for lnum, line in ipairs(vim.fn.readfile(path)) do
    local col = line:find(needle, 1, true)
    if col then
      vim.cmd('hide edit ' .. vim.fn.fnameescape(path))
      vim.api.nvim_win_set_cursor(0, { lnum, col - 1 + #'function ' })
      return true
    end
  end
  return false
end

return M
