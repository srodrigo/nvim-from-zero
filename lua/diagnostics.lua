local M = {}

local function jump(count, severity)
  vim.diagnostic.jump {
    count = count,
    severity = severity,
    on_jump = function()
      vim.diagnostic.open_float { scope = 'cursor', focus = false }
    end,
  }
end

function M.open_buffer_on_quickfix()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.diagnostic.setqflist {
    title = 'Buffer diagnostics',
    format = function(diagnostic)
      if diagnostic.bufnr == bufnr then
        return diagnostic.message
      end
    end,
  }
end

function M.previous()
  jump(-1)
end

function M.next()
  jump(1)
end

function M.previous_error()
  jump(-1, vim.diagnostic.severity.ERROR)
end

function M.next_error()
  jump(1, vim.diagnostic.severity.ERROR)
end

return M
