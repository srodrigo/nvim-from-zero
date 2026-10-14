local M = {}
local fzf = require('fzf-lua')
local fzf_actions = require('fzf-lua.actions')

local function report_error(err)
  vim.notify(err.message or tostring(err), vim.log.levels.ERROR)
end

local function show_locations(items, prompt)
  if #items == 0 then
    vim.notify('No ' .. prompt:lower() .. ' found')
    return
  end

  local entries = {}
  for _, item in ipairs(items) do
    entries[#entries + 1] = string.format('%s:%d:%d: %s',
      item.filename, item.lnum, item.col, (item.text or ''):gsub('[\r\n]', ' '))
  end
  fzf.fzf_exec(entries, {
    prompt = prompt .. '> ',
    previewer = 'builtin',
    fzf_opts = { ['--no-multi'] = true },
    actions = { ['enter'] = fzf_actions.file_edit },
  })
end

function M.attach(client, bufnr)
  local function map(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = desc })
  end

  local function source_action(kind)
    return function()
      fzf.lsp_code_actions({
        jump1 = false,
        context = { only = { kind } },
        filter = function(action, client_id)
          return client_id == client.id and action.kind == kind
        end,
      })
    end
  end

  map('gD', function()
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    client:request('workspace/executeCommand', {
      command = '_typescript.goToSourceDefinition',
      arguments = { params.textDocument.uri, params.position },
    }, function(err, locations)
      if err then
        report_error(err)
      else
        show_locations(vim.lsp.util.locations_to_items(locations or {}, client.offset_encoding), 'Source definitions')
      end
    end, bufnr)
  end, 'Go to source definition')

  map('gR', function()
    client:request('workspace/executeCommand', {
      command = 'typescript.tsserverRequest',
      arguments = { 'fileReferences', { file = vim.api.nvim_buf_get_name(bufnr) } },
    }, function(err, result)
      if err then
        report_error(err)
        return
      end
      if not result or not result.success then
        vim.notify(result and result.message or 'File references request failed', vim.log.levels.ERROR)
        return
      end

      local items = {}
      for _, ref in ipairs(result.body and result.body.refs or {}) do
        items[#items + 1] = {
          filename = ref.file,
          lnum = ref.start.line,
          col = ref.start.offset,
          text = ref.lineText or '',
        }
      end
      show_locations(items, 'File references')
    end, bufnr)
  end, 'File references')

  map('<leader>co', source_action('source.organizeImports.ts'), 'Organize imports')
  map('<leader>cm', source_action('source.addMissingImports.ts'), 'Add missing imports')
  map('<leader>cu', source_action('source.removeUnusedImports.ts'), 'Remove unused imports')
  map('<leader>cF', source_action('source.fixAll.ts'), 'Fix all diagnostics')
end

return M
