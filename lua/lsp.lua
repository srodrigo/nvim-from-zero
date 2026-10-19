local config_dir = vim.fs.normalize(vim.fn.stdpath('config'))

vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  settings = {},
  root_dir = function(bufnr, on_dir)
    local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))

    if path == config_dir or vim.startswith(path, config_dir .. '/') then
      on_dir(config_dir)
      return
    end

    on_dir(vim.fs.root(bufnr, { 'main.lua', 'conf.lua', '.luarc.json', '.luarc.jsonc', '.git' }) or vim.fs.dirname(path))
  end,
  before_init = function(_, config)
    local root = config.root_dir
    local lua_settings

    if root == config_dir then
      lua_settings = {
        runtime = { version = 'LuaJIT' },
        workspace = { library = { vim.env.VIMRUNTIME } },
        diagnostics = { globals = { 'vim' } },
      }
    elseif root and (vim.uv.fs_stat(root .. '/main.lua') or vim.uv.fs_stat(root .. '/conf.lua')) then
      lua_settings = {
        runtime = {
          version = 'LuaJIT',
          special = { ['love.filesystem.load'] = 'loadfile' },
        },
        diagnostics = { globals = { 'love' } },
        workspace = {
          checkThirdParty = false,
          library = { '${3rd}/love2d/library' },
        },
      }
    end

    if lua_settings then
      config.settings.Lua = vim.tbl_deep_extend('force', config.settings.Lua or {}, lua_settings)
    end
  end,
})

vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact' },
  root_dir = function(bufnr, on_dir)
    local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
    on_dir(vim.fs.root(bufnr, { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' }) or vim.fs.dirname(path))
  end,
})

vim.lsp.config('fennel_ls', {
  cmd = { 'fennel-ls' },
  filetypes = { 'fennel' },
  root_dir = function(bufnr, on_dir)
    local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
    on_dir(vim.fs.root(bufnr, { 'flsproject.fnl', '.git' }) or vim.fs.dirname(path))
  end,
})

vim.lsp.config('phpactor', {
  cmd = { 'phpactor', 'language-server' },
  filetypes = { 'php' },
  root_dir = function(bufnr, on_dir)
    local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
    on_dir(vim.fs.root(bufnr, { '.phpactor.json', '.phpactor.yml', 'composer.json', '.git' }) or vim.fs.dirname(path))
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    local function map(modes, keys, action, desc)
      vim.keymap.set(modes, keys, action, { buffer = event.buf, desc = desc })
    end

    if client:supports_method('textDocument/completion') then
      if client.name == 'fennel_ls' then
        -- fennel-ls completes dotted names, but only advertises brackets as triggers.
        local triggers = client.server_capabilities.completionProvider.triggerCharacters or {}
        if not vim.tbl_contains(triggers, '.') then
          table.insert(triggers, '.')
        end
        client.server_capabilities.completionProvider.triggerCharacters = triggers
      end
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
    if client:supports_method('textDocument/definition') then
      map('n', 'gd', function()
        if client.name == 'fennel_ls' then
          local fennel_definition = require('fennel_definition')
          if fennel_definition.go_to_required_module() or fennel_definition.go_to_love_metadata() then
            return
          end
        end
        require('fzf-lua').lsp_definitions({ jump1 = false, fzf_opts = { ['--no-multi'] = true } })
      end, 'Go to definition')
    end
    if client:supports_method('textDocument/references') then
      map('n', 'gr', function()
        require('fzf-lua').lsp_references({ jump1 = false, fzf_opts = { ['--no-multi'] = true } })
      end, 'Symbol references')
    end
    if client:supports_method('textDocument/implementation') then
      map('n', 'gI', require('fzf-lua').lsp_implementations, 'Go to implementation')
    end
    if client:supports_method('textDocument/typeDefinition') then
      map('n', 'gT', require('fzf-lua').lsp_typedefs, 'Go to type definition')
    end
    if client:supports_method('textDocument/documentSymbol') then
      map('n', '<leader>cs', require('fzf-lua').lsp_document_symbols, 'Document symbols')
    end
    if client:supports_method('textDocument/codeAction') then
      map({ 'n', 'v' }, '<leader>ca', require('fzf-lua').lsp_code_actions, 'Code actions')
    end
    if client:supports_method('textDocument/rename') then
      map('n', '<leader>cr', vim.lsp.buf.rename, 'Rename symbol')
    end
    if client.name == 'ts_ls' then
      require('typescript').attach(client, event.buf)
    end
  end,
})

vim.lsp.enable('lua_ls')
vim.lsp.enable('ts_ls')
vim.lsp.enable('fennel_ls')
vim.lsp.enable('phpactor')

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.lua',
  callback = function(event)
    if not vim.g.format_on_save then
      return
    end
    if #vim.lsp.get_clients({ bufnr = event.buf, method = 'textDocument/formatting' }) == 0 then
      return
    end
    vim.lsp.buf.format({ bufnr = event.buf, name = 'lua_ls', timeout_ms = 1000 })
  end,
})
