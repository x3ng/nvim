# nvim

## Structure

```
init.lua → require("cfg.init")
lua/
└── cfg/
    ├── init.lua                 top-level orchestration
    ├── core.lua                 editor settings
    ├── lazy-vim.lua             bootstrap
    ├── <plugin>.lua             one file per plugin spec
    └── lsp/                     LSP subsystem (self-contained)
        ├── init.lua             server configs + plugin imports
        ├── <lang>.lua           per-language LSP config
        └── <tool>.lua           LSP-related plugin specs
```

## Files

- `lua/cfg/init.lua` — entry point, `require()` + `lazy.setup()`
- `lua/cfg/core.lua` — editor settings, indent toggle
- `lua/cfg/lazy-vim.lua` — lazy.nvim bootstrap
- `lua/cfg/themery.lua` — theme switcher
- `lua/cfg/neo-tree.lua` — file tree
- `lua/cfg/telescope.lua` — fuzzy finder
- `lua/cfg/blink-cmp.lua` — completion
- `lua/cfg/bufferline.lua` — buffer tabs
- `lua/cfg/render-markdown.lua` — markdown renderer
- `lua/cfg/which-key.lua` — key hints
- `lua/cfg/lsp/init.lua` — LSP orchestration: server configs + plugin imports
- `lua/cfg/lsp/lsp-config.lua` — diagnostics + LSP keymaps
- `lua/cfg/lsp/python.lua` — pyright
- `lua/cfg/lsp/lua.lua` — lua_ls
- `lua/cfg/lsp/cc.lua` — clangd
- `lua/cfg/lsp/mason.lua` — LSP package manager
- `lua/cfg/lsp/conform.lua` — formatter
- `lua/cfg/lsp/trouble.lua` — diagnostics UI
- `lua/cfg/lsp/fidget.lua` — LSP progress
- `lua/cfg/lsp/haskell.lua` — haskell-language-server
- `lua/cfg/lsp/markdown.lua` — marksman

## Conventions

- Everything under `cfg.` namespace — prevents require() shadowing plugins
- One spec per file — add/remove = add/delete a file
- `lsp/` is autonomous — adding a language or LSP tool only touches `lsp/`
