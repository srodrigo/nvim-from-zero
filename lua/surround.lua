local pairs = {
  ['('] = ')', [')'] = ')', b = ')',
  ['['] = ']', [']'] = ']', r = ']',
  ['{'] = '}', ['}'] = '}', B = '}',
  ['<'] = '>', ['>'] = '>', a = '>',
  ['"'] = '"', ["'"] = "'", ['`'] = '`',
}

local reverse = { [')'] = '(', [']'] = '[', ['}'] = '{', ['>'] = '<' }

local function delimiter()
  local key = vim.fn.getcharstr()
  if key == '\027' then return nil end
  local right = pairs[key]
  if not right then
    vim.notify('Unsupported surround: ' .. key, vim.log.levels.WARN)
    return nil
  end
  return reverse[right] or key, right
end

local function wrap(start_row, start_col, end_row, end_col)
  local left, right = delimiter()
  if not left then return end
  local buf = 0
  local text = vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})
  text[1] = left .. text[1]
  text[#text] = text[#text] .. right
  vim.api.nvim_buf_set_text(buf, start_row, start_col, end_row, end_col, text)
end

local function operator(kind)
  local first = vim.api.nvim_buf_get_mark(0, '[')
  local last = vim.api.nvim_buf_get_mark(0, ']')
  local start_row, start_col = first[1] - 1, first[2]
  local end_row, end_col = last[1] - 1, last[2]
  if kind == 'line' then
    start_col = 0
    end_col = #vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, true)[1]
  else
    end_col = end_col + 1 -- Operator marks include the last character.
  end
  wrap(start_row, start_col, end_row, end_col)
end

local function visual()
  local anchor = vim.fn.getpos('v')
  local cursor = vim.api.nvim_win_get_cursor(0)
  local a = { anchor[2] - 1, anchor[3] - 1 }
  local b = { cursor[1] - 1, cursor[2] }
  if a[1] > b[1] or (a[1] == b[1] and a[2] > b[2]) then a, b = b, a end
  if vim.fn.mode() == 'V' then
    a[2] = 0
    b[2] = #vim.api.nvim_buf_get_lines(0, b[1], b[1] + 1, true)[1]
  else
    b[2] = b[2] + 1
  end
  wrap(a[1], a[2], b[1], b[2])
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
end

local function before_or_at(a, b)
  return a[1] < b[1] or (a[1] == b[1] and a[2] <= b[2])
end

local function enclosing(left, right)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local here = { cursor[1], cursor[2] }
  local best
  local stack = {}
  for row, line in ipairs(lines) do
    local quote
    for byte = 1, #line do
      local char = line:sub(byte, byte)
      local pos = { row, byte - 1 }
      if left == right then
        if char == left then
          local slashes = 0
          for i = byte - 1, 1, -1 do
            if line:sub(i, i) ~= '\\' then break end
            slashes = slashes + 1
          end
          if slashes % 2 == 0 then
            if quote then
              if before_or_at(quote, here) and before_or_at(here, pos) then
                best = { quote, pos }
              end
              quote = nil
            else
              quote = pos
            end
          end
        end
      elseif char == left then
        stack[#stack + 1] = pos
      elseif char == right and #stack > 0 then
        local start = table.remove(stack)
        if before_or_at(start, here) and before_or_at(here, pos)
          and (not best or before_or_at(best[1], start)) then
          best = { start, pos }
        end
      end
    end
  end
  return best
end

local function edit(change)
  local old_left, old_right = delimiter()
  if not old_left then return end
  local replacement_left, replacement_right = '', ''
  if change then
    replacement_left, replacement_right = delimiter()
    if not replacement_left then return end
  end
  local found = enclosing(old_left, old_right)
  if not found then
    vim.notify('No surrounding ' .. old_left .. old_right .. ' found', vim.log.levels.WARN)
    return
  end
  local first, last = found[1], found[2]
  local text = vim.api.nvim_buf_get_text(0, first[1] - 1, first[2], last[1] - 1, last[2] + 1, {})
  if #text == 1 then
    text[1] = replacement_left .. text[1]:sub(2, -2) .. replacement_right
  else
    text[1] = replacement_left .. text[1]:sub(2)
    text[#text] = text[#text]:sub(1, -2) .. replacement_right
  end
  vim.api.nvim_buf_set_text(0, first[1] - 1, first[2], last[1] - 1, last[2] + 1, text)
end

local function setup()
  _G.SurroundOperator = operator
  vim.keymap.set('n', 'ys', function()
    vim.go.operatorfunc = 'v:lua.SurroundOperator'
    return 'g@'
  end, { expr = true, desc = 'Surround motion' })
  vim.keymap.set('n', 'yss', function()
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line = vim.api.nvim_get_current_line()
    wrap(row, 0, row, #line)
  end, { desc = 'Surround line' })
  vim.keymap.set('x', 'S', visual, { desc = 'Surround selection' })
  vim.keymap.set('n', 'ds', function() edit(false) end, { desc = 'Delete surround' })
  vim.keymap.set('n', 'cs', function() edit(true) end, { desc = 'Change surround' })
end

setup()
