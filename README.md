# Minimal Neovim config

Neovim 0.12+ configuration for Lua and LÖVE. It uses native LSP and completion,
and installs `nvim-treesitter` and `nvim-tree` with Neovim's `vim.pack`.

## Requirements

- `nvim` 0.12+, `git`, `lua-language-server`, `tree-sitter` 0.26.1+, and a C compiler in `PATH`
- Network access on the first launch to fetch the plugin and Lua parser

Run this config with `NVIM_APPNAME=nvim-from-zero nvim`, or rename its directory
to `~/.config/nvim` to make it your default config.

LuaLS gets Neovim runtime definitions when editing this config. In a project
whose root has `main.lua` or `conf.lua`, it gets LuaJIT settings and LÖVE API
definitions. Run a game from the project root with `love .`.

Use `:checkhealth vim.lsp` and `:checkhealth nvim-treesitter` to inspect the
setup. After updating `nvim-treesitter` with `:lua vim.pack.update()`, run
`:TSUpdate` to update its Lua parser. Neovim's built-in LSP mappings include
`K` for hover, `grn` for rename, and `gra` for code actions. Accept a completion
item with `<C-y>`.
