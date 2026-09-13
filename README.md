# nvim

## Structure

```
init.lua → require("cfg.init")
lua/
└── cfg/
    ├── init.lua                 top-level orchestration
    ├── base/                    editor settings, keymaps, theme (no plugins)
    │   ├── init.lua             options + editing keymaps
    │   └── theme.lua            colorscheme + transparency
    ├── lazy-nvim.lua            lazy.nvim bootstrap
    ├── mason.lua                tool installer backend
    ├── <plugin>.lua             one file per plugin spec
    ├── format/                  formatter subsystem
    │   ├── conform.lua          formatter behavior
    │   └── tools.lua            formatter tool install registry
    └── lsp/                     LSP subsystem (self-contained)
        ├── init.lua             native LSP setup from server registry
        ├── servers.lua          LSP server registry shared by runtime + Mason
        └── lsp-config.lua       diagnostics + LSP keymaps
```

## Files

- `lua/cfg/init.lua` — entry point, wires layers + `lazy.setup()`
- `lua/cfg/base/init.lua` — options + editing keymaps (plugin-independent)
- `lua/cfg/base/theme.lua` — colorscheme default + local persistence (`~/.local/state/nvim/user-theme`) and transparency (`user-transparent`)
- `lua/cfg/themes/*.lua` — color plugin specs; each flavour is its own colorscheme name
- `lua/cfg/lazy-nvim.lua` — lazy.nvim bootstrap
- `lua/cfg/mason.lua` — Mason installer backend + formatter/tools drift check
- `lua/cfg/treesitter.lua` — parser list (`ensure_installed`, auto-installs), highlighting, indentexpr, folds, textobjects (main branch API)
- `lua/cfg/treesitter-context.lua` — sticky function/class header
- `lua/cfg/ts-comments.lua` — treesitter-driven commenting (`gc`)
- `lua/cfg/todo-comments.lua` — TODO/FIXME highlighting + `]t`/`[t` jumps
- `lua/cfg/blink-cmp.lua` — completion (insert + cmdline)
- `lua/cfg/mini-pairs.lua` — auto-pairs (no `<CR>` remap, so blink keeps accept)
- `lua/cfg/flash.lua` — jump navigation
- `lua/cfg/surround.lua` — `ys`/`cs`/`ds` surround operations
- `lua/cfg/grug-far.lua` — project-wide search & replace (`<leader>sr`)
- `lua/cfg/persistence.lua` — session save/load (`<leader>qs`)
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

- Two layers: `cfg.base/*` runs before plugins (no plugin dependencies allowed there); everything else is a lazy spec
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
- Themes: browse with `<leader>uC` (Snacks picker, live preview); picked theme persists to state dir, `default` in `cfg/base/theme.lua` is the factory fallback; `<leader>ut` toggles transparency
- LSP keymaps: 0.12 built-ins stay authoritative (`gr*` family, `K`, `<C-s>`, `gO`); this config only adds `gd`/`gD`, `<leader>df` (diagnostics float), `<leader>uh` (inlay hints), `<leader>lr` (`:lsp restart`)
- `<leader>s` groups search & replace (`sr` grug-far, `sw`/`sb`/`sv` prefill, `st` TODOs); `<leader>q` groups sessions (`qs` load, `qS` select, `ql` last, `qd` stop)
- Filetypes: `.cu` uses the `cuda` parser; `.v`/`.vh` reuse `systemverilog` via `vim.treesitter.language.register`
- `lua/cfg/treesitter.lua`'s `ensure_installed` is the single source of truth for parsers — missing ones are installed automatically on startup
