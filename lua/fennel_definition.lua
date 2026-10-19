local M = {}

function M.go_to_required_module()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local module

  for _, start, name, finish in line:gmatch('()%(%s*require%s+()"([%w_.%-]+)"()') do
    if col >= start - 1 and col < finish - 1 then
      module = name
      break
    end
  end
  if not module then
    for _, start, name, finish in line:gmatch('()%(%s*require%s+():([%w_.%-]+)()') do
      if col >= start - 1 and col < finish - 1 then
        module = name
        break
      end
    end
  end
  if not module then
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'fennel_ls' })[1]
  local root = client and client.config.root_dir
    or vim.fs.root(bufnr, { 'flsproject.fnl', '.git' })
  if not root then
    return false
  end

  local relative = module:gsub('%.', '/')
  for _, suffix in ipairs({ '.fnl', '/init.fnl' }) do
    local path = vim.fs.joinpath(root, relative .. suffix)
    if vim.uv.fs_stat(path) then
      vim.cmd('hide edit ' .. vim.fn.fnameescape(path))
      return true
    end
  end
  return false
end

local function symbol_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  for start, symbol in line:gmatch('()([%a_][%w_%.]*)') do
    if col >= start - 1 and col < start - 1 + #symbol then
      return symbol
    end
  end
end

local function lua_metadata()
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
    local metadata = vim.fs.joinpath(parent, 'meta')
    if vim.uv.fs_stat(vim.fs.joinpath(metadata, 'template', 'table.lua')) then
      return metadata
    end
  end
end

function M.go_to_love_metadata()
  local symbol = symbol_at_cursor()
  if not symbol or not symbol:match('^love%.[%w_%.]+$') then
    return false
  end

  local metadata = lua_metadata()
  if not metadata then
    return false
  end

  local library = vim.fs.joinpath(metadata, '3rd', 'love2d', 'library')
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

function M.go_to_lua_metadata()
  local symbol = symbol_at_cursor()
  if not symbol then
    return false
  end

  local module = symbol:match('^([%a_][%w_]*)%.[%a_][%w_]*$')
  if not module or not vim.tbl_contains({
    'table', 'string', 'math', 'io', 'os', 'coroutine', 'package', 'debug', 'utf8', 'bit', 'bit32',
  }, module) then
    return false
  end

  local metadata = lua_metadata()
  local path = metadata and vim.fs.joinpath(metadata, 'template', module .. '.lua')
  if not path or not vim.uv.fs_stat(path) then
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
