local M = {}

function M.delete_all_other_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_get_option_value('buflisted', { buf = buf })
      and not vim.api.nvim_get_option_value('modified', { buf = buf })
      and buf ~= vim.api.nvim_get_current_buf()
    then
      vim.api.nvim_buf_delete(buf, {})
    end
  end
end

return M
