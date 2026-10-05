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
    ├── mason.lua                install missing language tools and check formatters
    ├── <plugin>.lua             one file per plugin spec
    ├── format/                  formatter subsystem
    │   ├── conform.lua          formatter behavior
    │   └── tools.lua            formatter tool install registry
    └── lsp/                     LSP subsystem (self-contained)
        ├── init.lua             native LSP setup from server registry
        ├── servers.lua          LSP server registry
        └── lsp-config.lua       diagnostics + LSP keymaps
```

## Files

- `lua/cfg/init.lua` — entry point, wires layers + `lazy.setup()`
- `lua/cfg/base/init.lua` — options + editing keymaps (plugin-independent)
- `lua/cfg/base/theme.lua` — colorscheme default + local persistence (`~/.local/state/nvim/user-theme`) and transparency (`user-transparent`)
- `lua/cfg/themes/*.lua` — color plugin specs; each flavour is its own colorscheme name
- `lua/cfg/lazy-nvim.lua` — lazy.nvim bootstrap
- `lua/cfg/mason.lua` — install missing LSP servers, formatters and Tree-sitter CLI; formatter/tools drift check
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
- `lua/cfg/oil.lua` — filesystem editing (`<leader>ce`); browsing uses Snacks explorer
- `lua/cfg/guess-indent.lua` — detect existing file indentation while respecting EditorConfig
- `lua/cfg/snacks.lua` — picker, terminal, notifier, lazygit, statuscolumn, etc.
- `lua/cfg/noice.lua` — command input overlays the statusline; output uses one theme-matched split buffer; Snacks renders other notifications, Blink handles command completion
- `lua/cfg/lualine.lua` — single-line global statusline (+ macro recording indicator)
- `lua/cfg/gitsigns.lua` — git gutter and hunks
- `lua/cfg/markdown-preview.lua` — local browser preview server for Markdown; Neovim keeps source view with Tree-sitter highlighting
- `lua/cfg/lazydev.lua` — nvim Lua dev support
- `lua/cfg/which-key.lua` — key hints
- `lua/cfg/format/conform.lua` — formatter
- `lua/cfg/format/tools.lua` — formatter tool install registry
- `lua/cfg/lsp/init.lua` — LSP orchestration: registers servers, enables available ones and reports missing ones to Mason
- `lua/cfg/lsp/servers.lua` — LSP server registry aligned with `~/nix-config/home/packages.nix`: ty, ts_ls, nil_ls, lua_ls, clangd, marksman, verible, rust_analyzer, jsonls, html, cssls, yamlls, taplo, bashls
- `lua/cfg/lsp/lsp-config.lua` — diagnostics + LSP keymaps

## Conventions

- Two layers: `cfg.base/*` runs before plugins (no plugin dependencies allowed there); everything else is a lazy spec
- Everything under `cfg.` namespace — prevents require() shadowing plugins
- One spec per file — add/remove = add/delete a file
- LSP servers are declared once in `lua/cfg/lsp/servers.lua`; project, Nix, system and Mason binaries are all supported
- Native `vim.lsp.config()` / `vim.lsp.enable()` owns runtime LSP setup
- Formatter tools are declared once in `lua/cfg/format/tools.lua`
- Mason installs only tools whose executables are absent from `PATH` and its own bin directory, then appends its bin directory to `PATH`
- Project, system, and Home Manager tools in `PATH` take precedence over Mason-installed tools
- Missing LSP servers are enabled when Mason finishes installing them
- Formatter configuration lives under `lua/cfg/format/`
- Themes: browse with `<leader>uC` (Snacks picker, live preview); picked theme persists to state dir, `default` in `cfg/base/theme.lua` is the factory fallback; `<leader>ut` toggles transparency
- LSP keymaps: 0.12 built-ins stay authoritative (`gr*` family, `K`, `<C-s>`, `gO`); this config only adds `gd`/`gD`, `<leader>df` (diagnostics float), `<leader>uh` (inlay hints), `<leader>lr` (`:lsp restart`)
- Navigation: Snacks floating pickers only — `ff` files, `fe` directory tree, `fb` buffers, `fs` document symbols, `fS` workspace symbols, `fd` diagnostics, `fD` buffer diagnostics (all with `<leader>`); file/symbol selection closes the picker
- File operations: `<leader>ce` edits the current file's directory with Oil; references use native `grr`; terminal toggles with `<C-\>`; notifications use `<leader>nh`/`nd`
- Editing: indentation follows EditorConfig or file detection; `:SetIndent [space|tab] <width>` overrides the current buffer. `<leader>w` saves, `<leader>qq` quits all; native `<C-w>q` closes a window
- `<leader>s` groups search & replace (`sr` grug-far, `sw`/`sb`/`sv` prefill, `st` TODOs); `<leader>q` groups sessions (`qs` load, `qS` select, `ql` last, `qd` stop)
- Markdown: Neovim stays in highlighted source view; `<leader>mp` starts/stops the browser preview at `localhost:8080`
- Filetypes: `.cu` uses the `cuda` parser; `.v`/`.vh` reuse `systemverilog` via `vim.treesitter.language.register`
- `lua/cfg/treesitter.lua`'s `ensure_installed` is the single source of truth for parsers — missing ones are installed automatically on startup
