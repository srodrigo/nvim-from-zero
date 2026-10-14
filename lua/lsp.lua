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

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
    if client and client:supports_method('textDocument/definition') then
      vim.keymap.set('n', 'gd', function()
        require('fzf-lua').lsp_definitions({ jump1 = false, fzf_opts = { ['--no-multi'] = true } })
      end, { buffer = event.buf, desc = 'Go to definition' })
    end
    if client and client:supports_method('textDocument/references') then
      vim.keymap.set('n', 'gr', function()
        require('fzf-lua').lsp_references({ jump1 = false, fzf_opts = { ['--no-multi'] = true } })
      end, { buffer = event.buf, desc = 'Symbol references' })
    end
    if client and client.name == 'ts_ls' then
      require('typescript').attach(client, event.buf)
    end
  end,
})

vim.lsp.enable('lua_ls')
vim.lsp.enable('ts_ls')

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.lua',
  callback = function(event)
    if #vim.lsp.get_clients({ bufnr = event.buf, method = 'textDocument/formatting' }) == 0 then
      return
    end
    vim.lsp.buf.format({ bufnr = event.buf, name = 'lua_ls', timeout_ms = 1000 })
  end,
})
