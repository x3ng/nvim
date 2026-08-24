# nvim

## Structure

```
init.lua → require("cfg.init")
lua/
└── cfg/
    ├── init.lua                 top-level orchestration
    ├── core.lua                 editor settings
    ├── lazy-nvim.lua            lazy.nvim bootstrap
    ├── mason.lua                tool installer backend
    ├── <plugin>.lua             one file per plugin spec
    ├── format/                  formatter subsystem
    │   ├── conform.lua          formatter behavior
    │   └── tools.lua            formatter tool install registry
    └── lsp/                     LSP subsystem (self-contained)
        ├── init.lua             native LSP setup from server registry
        ├── servers.lua          LSP server registry shared by runtime + Mason
        ├── lsp-config.lua       diagnostics + LSP keymaps
        └── <tool>.lua           LSP-related plugin specs
```

## Files

- `lua/cfg/init.lua` — entry point, `require()` + `lazy.setup()`
- `lua/cfg/core.lua` — editor settings, indent toggle, QoL keymaps
- `lua/cfg/lazy-nvim.lua` — lazy.nvim bootstrap
- `lua/cfg/mason.lua` — Mason installer backend for LSP servers and formatter tools
- `lua/cfg/themery.lua` — theme switcher
- `lua/cfg/transparent.lua` — transparent background controller
- `lua/cfg/treesitter.lua` — parsers, highlighting, indentexpr, folds, textobjects (main branch API)
- `lua/cfg/ts-comments.lua` — treesitter-driven commenting (`gc`)
- `lua/cfg/blink-cmp.lua` — completion (insert + cmdline)
- `lua/cfg/flash.lua` — jump navigation
- `lua/cfg/fcitx.lua` — input method auto-switch
- `lua/cfg/oil.lua` — file manager
- `lua/cfg/snacks.lua` — picker, terminal, notifier, lazygit, statuscolumn, etc.
- `lua/cfg/lualine.lua` — single-line global statusline (+ macro recording indicator)
- `lua/cfg/gitsigns.lua` — git gutter and hunks
- `lua/cfg/render-markdown.lua` — markdown renderer
- `lua/cfg/lazydev.lua` — nvim Lua dev support
- `lua/cfg/which-key.lua` — key hints
- `lua/cfg/format/conform.lua` — formatter
- `lua/cfg/format/tools.lua` — formatter tool install registry
- `lua/cfg/lsp/init.lua` — LSP orchestration: registers servers, enables installed ones, warns on missing binaries
- `lua/cfg/lsp/servers.lua` — LSP server registry: pyright, lua_ls, clangd, marksman, verible, rust_analyzer, vtsls
- `lua/cfg/lsp/lsp-config.lua` — diagnostics + LSP keymaps

## Conventions

- Everything under `cfg.` namespace — prevents require() shadowing plugins
- One spec per file — add/remove = add/delete a file
- LSP servers are declared once in `lua/cfg/lsp/servers.lua`
- Native `vim.lsp.config()` / `vim.lsp.enable()` owns runtime LSP setup
- Formatter tools are declared once in `lua/cfg/format/tools.lua`
- Mason consumes LSP and formatter registries for installation only and appends its bin directory to `PATH`
- System, Nix/home-manager, or project environment tools take precedence; Mason-installed tools act as fallback
- Set `mason = false` only for servers that Mason should never install
- Server entries may use conditional `mason` values when Mason needs extra installer dependencies
- Formatter configuration lives under `lua/cfg/format/`
