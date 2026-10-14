local map = vim.keymap.set

local closing_for = {
  ['('] = ')',
  ['['] = ']',
  ['{'] = '}',
  ['"'] = '"',
  ["'"] = "'",
  ['`'] = '`',
}

local function around_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  return line:sub(col, col), line:sub(col + 1, col + 1)
end

for opening, closing in pairs(closing_for) do
  if opening ~= closing then
    map('i', opening, function()
      return opening .. closing .. '<Left>'
    end, { expr = true, desc = 'Insert matching ' .. closing })

    map('i', closing, function()
      local _, next_char = around_cursor()
      return next_char == closing and '<Right>' or closing
    end, { expr = true, desc = 'Skip matching ' .. closing })
  else
    map('i', opening, function()
      local previous, next_char = around_cursor()
      if next_char == opening then
        return '<Right>'
      end
      -- Keep apostrophes and quotes within words, and escaped quotes, literal.
      if previous == '\\' or previous:match('[%w_]') or next_char:match('[%w_]') then
        return opening
      end
      return opening .. opening .. '<Left>'
    end, { expr = true, desc = 'Pair or skip ' .. opening })
  end
end

map('i', '<BS>', function()
  local previous, next_char = around_cursor()
  if closing_for[previous] == next_char then
    return '<BS><Del>'
  end
  return '<BS>'
end, { expr = true, desc = 'Delete an empty pair' })
