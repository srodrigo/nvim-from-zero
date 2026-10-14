local fzf = require('fzf-lua')
local actions = require('fzf-lua.actions')
local map = vim.keymap.set

local function project_excludes()
  local cwd = vim.fn.getcwd()
  local root = vim.fs.root(cwd, '.git')
  local excludes = {}
  if not root then
    return excludes
  end

  for _, path in ipairs { 'lib/2dengine-love.js', 'lib/luaunit' } do
    local full_path = root .. '/' .. path
    local relative = vim.fs.relpath(cwd, full_path)
    if relative and vim.fn.isdirectory(full_path) == 1 then
      table.insert(excludes, relative)
    end
  end
  return excludes
end

local function find_project_files()
  local fd_opts = '--color=never --type f --type l --exclude .git --exclude .jj'
  local rg_opts = '--color=never --files -g "!.git" -g "!.jj"'
  for _, path in ipairs(project_excludes()) do
    fd_opts = fd_opts .. ' --exclude ' .. vim.fn.shellescape(path)
    rg_opts = rg_opts .. ' -g ' .. vim.fn.shellescape('!' .. path .. '/**')
  end
  fzf.files { fd_opts = fd_opts, rg_opts = rg_opts }
end

local function grep_project(use_globs)
  local rg_opts = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096'
  for _, path in ipairs(project_excludes()) do
    rg_opts = rg_opts .. ' -g ' .. vim.fn.shellescape('!' .. path .. '/**')
  end
  rg_opts = rg_opts .. ' -e'
  if use_globs then
    fzf.live_grep { rg_opts = rg_opts }
  else
    fzf.live_grep_native { rg_opts = rg_opts }
  end
end

fzf.setup {
  'telescope',
  winopts = {
    height = 0.95,
    width = 0.95,
    preview = {
      delay = 50,
      vertical = 'down:45%',
      horizontal = 'right:60%',
      layout = 'flex',
    },
  },
  files = {
    actions = {
      ['ctrl-i'] = { actions.toggle_ignore },
      ['ctrl-h'] = { actions.toggle_hidden },
    },
  },
  grep = {
    actions = {
      ['ctrl-g'] = { actions.grep_lgrep },
      ['ctrl-i'] = { actions.toggle_ignore },
      ['ctrl-h'] = { actions.toggle_hidden },
    },
  },
  fzf_opts = {
    ['--history'] = vim.fn.stdpath('data') .. '/fzf-lua-history',
  },
}

-- Buffers and files
map('n', '<leader>bb', '<cmd>FzfLua buffers<cr>', { desc = 'Search buffers' })
map('n', '<leader>fb', '<cmd>FzfLua buffers<cr>', { desc = 'Find buffers' })
map('n', '<leader><leader>', find_project_files, { desc = 'Find files' })
map('n', '<leader>ff', find_project_files, { desc = 'Find files' })
map('n', '<leader>fa', function()
  fzf.files { cmd = 'rg --color=never --files --ignore-case --hidden --no-ignore -g "!.git"' }
end, { desc = 'Find all files, including hidden and ignored' })
map('n', '<leader>f.', function()
  fzf.oldfiles { cwd_only = true }
end, { desc = 'Find recent files here' })

-- Git
map('n', '<leader>gg', '<cmd>FzfLua git_status<cr>', { desc = 'Search git status' })
map('n', '<leader>gh', '<cmd>FzfLua git_commits<cr>', { desc = 'Search git history' })

-- Neovim
map('n', '<leader>s:', '<cmd>FzfLua commands<cr>', { desc = 'Search Neovim commands' })
map('n', '<leader>sh', '<cmd>FzfLua helptags<cr>', { desc = 'Search help' })
map('n', '<leader>fh', '<cmd>FzfLua helptags<cr>', { desc = 'Find help' })
map('n', '<leader>sk', '<cmd>FzfLua keymaps<cr>', { desc = 'Search keymaps' })
map('n', '<leader>sm', '<cmd>FzfLua marks<cr>', { desc = 'Search marks' })
map('n', '<leader>sq', '<cmd>FzfLua quickfix<cr>', { desc = 'Search quickfix' })
map('n', '<leader>ss', '<cmd>FzfLua<cr>', { desc = 'Select FzfLua picker' })
map('n', '<leader>sc', function()
  fzf.files { cwd = vim.fn.stdpath('config') }
end, { desc = 'Search Neovim config' })

-- Text
map('n', '<leader>/', function() grep_project(false) end, { desc = 'Search text' })
map('n', '<leader>fg', function() grep_project(false) end, { desc = 'Find by grep' })
map('n', '<leader>sg', function() grep_project(false) end, { desc = 'Search by grep' })
map('n', '<leader>sf', function() grep_project(true) end, { desc = 'Search text with globs' })
map('n', '<leader>sa', function()
  fzf.live_grep_native {
    rg_opts = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden --no-ignore -g "!.git" -e',
  }
end, { desc = 'Search all text, including hidden and ignored' })

-- Diagnostics, symbols, and search history
map('n', '<leader>sd', '<cmd>FzfLua diagnostics_workspace<cr>', { desc = 'Search workspace diagnostics' })
map('n', '<leader>sw', '<cmd>FzfLua lsp_workspace_symbols<cr>', { desc = 'Search workspace symbols' })
map('n', '<leader>sb', '<cmd>FzfLua lsp_document_symbols<cr>', { desc = 'Search document symbols' })
map('n', '<leader>sr', '<cmd>FzfLua resume<cr>', { desc = 'Resume search' })
