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
    ├── mason.lua                explicit language-tool installation and formatter checks
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
- `lua/cfg/mason.lua` — explicit installation of missing LSP servers, formatters and Tree-sitter CLI; formatter/tools drift check
- `lua/cfg/treesitter.lua` — parser list (`:TSInstallConfigured`), highlighting, indentexpr, folds, textobjects (main branch API)
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
- `lua/cfg/readline.lua` — shared Insert and command-line Readline editing keys; see `docs/readline.md`
- Noice: routine messages expire after 2.5 seconds; errors, shell output, and messages of 4+ lines stay in a split without taking focus. `<leader>nm` opens editor message history; `<leader>nc` dismisses displayed messages without clearing history.
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
- `lua/cfg/format/indent.lua` — re-detect editing indentation after successful formatting, across languages
- `lua/cfg/format/cpp-indent.lua` — C/C++ project style resolution on open/rename; LLVM fallback only for files without existing indentation or EditorConfig
- `lua/cfg/format/tools.lua` — formatter tool install registry
- `lua/cfg/lsp/init.lua` — LSP orchestration: registers servers, enables available ones and reports missing ones to Mason
- `lua/cfg/lsp/servers.lua` — LSP server registry: ty, ts_ls, nil_ls, lua_ls, clangd, gopls, marksman, verible, rust_analyzer, jsonls, html, cssls, yamlls, taplo, bashls
- `lua/cfg/lsp/lsp-config.lua` — diagnostics + LSP keymaps

## Conventions

- Two layers: `cfg.base/*` runs before plugins (no plugin dependencies allowed there); everything else is a lazy spec
- Everything under `cfg.` namespace — prevents require() shadowing plugins
- One spec per file — add/remove = add/delete a file
- LSP servers are declared once in `lua/cfg/lsp/servers.lua`; project, system and Mason binaries are all supported
- Native `vim.lsp.config()` / `vim.lsp.enable()` owns runtime LSP setup
- Formatter tools are declared once in `lua/cfg/format/tools.lua`
- Mason appends its bin directory to `PATH`. `:MasonToolsInstall` explicitly installs tools found missing at startup; normal startup does not install tools or load the Mason LSP registry integration
- Tools already in `PATH` take precedence over Mason-installed tools
- Missing LSP servers are enabled when the explicit installer finishes. After adding tools through Nix or changing a project environment, restart Neovim from that environment
- Formatter configuration lives under `lua/cfg/format/`
- Themes: browse with `<leader>uC` (Snacks picker, live preview); picked theme persists to state dir, `default` in `cfg/base/theme.lua` is the factory fallback; `<leader>ut` toggles transparency
- LSP keymaps: 0.12 built-ins stay authoritative (`gr*` family, `K`, `<C-s>`, `gO`); this config only adds `gd`/`gD`, `<leader>df` (diagnostics float), `<leader>uh` (inlay hints), `<leader>lr` (`:lsp restart`)
- Navigation: Snacks floating pickers only — `ff` files, `fe` directory tree, `fb` buffers, `fs` document symbols, `fS` workspace symbols, `fd` diagnostics, `fD` buffer diagnostics (all with `<leader>`); file/symbol selection closes the picker
- File operations: `<leader>ce` edits the current file's directory with Oil; references use native `grr`; terminal toggles with `<C-/>`; notifications use `<leader>nh`/`nd`
- Editing: indentation follows EditorConfig or file detection; C/C++ project clang-format settings take precedence when available. Resolution runs asynchronously; duplicate opening events are coalesced and stale results never override later edits or manual indentation. Without a project style, existing indentation is preserved; new C/C++ files use LLVM's default when clang-format is available. `:SetIndent [space|tab] <width>` overrides editing indentation for the current buffer; `:lua vim.b.manual_indent = nil` restores automatic detection on the next read/format.
- Formatting is manual via `<leader>cf` (buffer or visual selection), using configured formatters with LSP fallback. Saving never formats; there are no autoformat toggles. After successful formatting, editing indentation is re-detected from the output unless `:SetIndent` pinned it. Manual formatting still uses formatter rules, which may differ from a pinned editing width. `<leader>w` saves, `<leader>qq` quits all; native `<C-w>q` closes a window
- `<leader>s` groups search & replace (`sr` grug-far, `sw`/`sb`/`sv` prefill, `st` TODOs); `<leader>q` groups sessions (`qs` load, `qS` select, `ql` last, `qd` stop)
- Markdown: Neovim stays in highlighted source view; `<leader>mp` starts/stops the browser preview at `localhost:8080`
- Filetypes: `.cu` uses the `cuda` parser; `.v`/`.vh` reuse `systemverilog` via `vim.treesitter.language.register`
- `lua/cfg/treesitter.lua`'s `ensure_installed` is the single source of truth for parsers — install missing ones explicitly with `:TSInstallConfigured`; reopen affected buffers after installation

## Tool setup and checks

- Prefer the project's `nix develop` environment or Nix-provided executables. Existing `PATH` tools take precedence; Mason is an optional fallback, not a second mandatory installation.
- Run `:MasonToolsInstall` to install the configured missing LSP/formatter tools, or `:LspInstall <server>` for one server. Use `:Mason` to inspect installed packages. Tools without a Mason-managed source (such as `nixfmt`, `gofmt`, and `rustfmt`) still come from Nix/the language toolchain.
- Run `:TSInstallConfigured` to install missing parsers, and `:TSUpdate` when explicitly updating them. Plugin builds may also run `:TSUpdate`.
- In an affected project file, use `:checkhealth vim.lsp`, `:lua vim.print(vim.lsp.get_clients({bufnr = 0}))`, `:ConformInfo`, and `:checkhealth blink.cmp` to inspect attachment, roots, tools and completion.
- nil's `nix.flake.autoArchive = false` disables fetching/prompting for missing flake inputs. Run `nix flake archive` manually when dependency-aware Nix completion is needed.
- Folding starts expanded; returning to a window does not reset the user's fold level. `vim.print` retains its native behavior; use `Snacks.debug.inspect(...)` explicitly for Snacks debug output.
