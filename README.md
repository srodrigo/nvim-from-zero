# Minimal Neovim config

Neovim 0.12+ configuration for Lua, LÖVE, and TypeScript. It uses native LSP and completion,
and installs `mason.nvim`, `conform.nvim`, `nvim-treesitter`, `nvim-tree`, `fzf-lua`, `gitsigns.nvim`, and
`vim-fugitive` with Neovim's `vim.pack`.

## Requirements

- `nvim` 0.12+, `git`, `lua-language-server`, `tree-sitter` 0.26.1+, a C compiler, `fzf` newer than 0.36, and `rg` in `PATH`
- `node` and `npm` to install and run the TypeScript language server through Mason
- Network access on the first launch to fetch the plugins and Lua, TypeScript, and TSX parsers

Run this config with `NVIM_APPNAME=nvim-from-zero nvim`, or rename its directory
to `~/.config/nvim` to make it your default config.

LuaLS gets Neovim runtime definitions when editing this config. In a project
whose root has `main.lua` or `conf.lua`, it gets LuaJIT settings and LÖVE API
definitions. Run a game from the project root with `love .`.

TypeScript LSP, completion, and Tree-sitter highlighting work for `.ts` and
`.tsx` files. Use `:MasonInstall typescript-language-server` to install the
server; Mason adds its executable to Neovim's `PATH`.

Lua files format on save through LuaLS. JavaScript and TypeScript files format
on save through Conform and Prettier. Install Prettier with `:MasonInstall prettier`;
Mason makes the executable available to Conform. Use `:ConformInfo` in a buffer
to check which formatter is available.

Use `gd` for a symbol's definition and `gr` for its references when an LSP is
attached. In TypeScript buffers, `gD` goes to source definition and `gR`
finds references to the current file. Use `<leader>co` to organize imports,
`<leader>cm` to add missing imports, `<leader>cu` to remove unused imports,
and `<leader>cF` to apply available TypeScript fixes. These mappings show
fzf-lua pickers, including when there is only one result.

Use `:checkhealth vim.lsp`, `:checkhealth mason`, and `:checkhealth nvim-treesitter` to inspect the
setup. After updating `nvim-treesitter` with `:lua vim.pack.update()`, run
`:TSUpdate` to update its parsers. Neovim's built-in LSP mappings include
`K` for hover, `grn` for rename, and `gra` for code actions. Accept a completion
item with `<C-y>`.

Toggle nvim-tree with `<leader>e`.
Insert-mode autopairs handle `()`, `[]`, `{}`, quotes, and backticks. Typing a
closer skips one already at the cursor; Backspace removes an empty pair.
Surround text with `ys` and a motion (`ysiw)`), `yss)` for a line, or visual
`S` followed by a delimiter. Use `ds)` to remove an enclosing pair and `cs)'`
to change it. Supported delimiters are `()`, `[]`, `{}`, `<>`, quotes, and
backticks; `b`, `r`, `B`, and `a` alias the four bracket pairs.
Use `<leader>ff` or `<leader><leader>` to find files, `<leader>fg` or
`<leader>sg` to search project text, `<leader>fb` or `<leader>bb` to switch
buffers, and `<leader>fh` or `<leader>sh` to search help. Use `<leader>fa`
and `<leader>sa` to include hidden and ignored files. Other fzf-lua shortcuts
are grouped under `<leader>s`, with git pickers under `<leader>g`.
Gitsigns shows changes in the sign column and line blame after 400 ms.
Use `[c` and `]c` to move between hunks, `<leader>gs` and `<leader>gr` to
stage or reset a hunk, and `<leader>gp` to preview one. Other git actions
include `<leader>gS` to stage the buffer, `<leader>gu` to undo staging,
`<leader>gR` to reset the buffer, and `<leader>gb` to show line blame.
Use `:Git` for Fugitive's Git status and commands, or `:Gdiffsplit` to compare
the current file with its Git version.
