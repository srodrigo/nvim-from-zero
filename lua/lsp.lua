local config_dir = vim.fs.normalize(vim.fn.stdpath('config'))

vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
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
        workspace = {
          checkThirdParty = false,
          library = { '${3rd}/love2d/library' },
        },
      }
    end

    if lua_settings then
      config.settings = vim.tbl_deep_extend('force', config.settings or {}, { Lua = lua_settings })
    end
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
  end,
})

vim.lsp.enable('lua_ls')
