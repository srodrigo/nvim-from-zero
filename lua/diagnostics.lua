local M = {}

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
  vim.diagnostic.jump { count = -1 }
end

function M.next()
  vim.diagnostic.jump { count = 1 }
end

function M.previous_error()
  vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.ERROR }
end

function M.next_error()
  vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.ERROR }
end

return M
