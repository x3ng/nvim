# nvim

## Structure

```
init.lua → require("cfg.init")
lua/
└── cfg/
    ├── init.lua                 top-level orchestration
    ├── core/                    shared options, editing keys, filetypes
    ├── standalone/              standalone options, keymaps, theme
    ├── vscode/                  vscode-neovim host settings + command bridges
    ├── plugins.lua              complete plugin inventory (host-filtered with cond)
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
- `lua/cfg/core/` — shared leader, search, editing keys and filetypes (plugin-independent)
- `lua/cfg/standalone/` — standalone UI, indentation, file watching, keymaps and theme
- `lua/cfg/vscode/` — VSCode/VSCodium host settings and command bridges
- `lua/cfg/plugins.lua` — full plugin inventory; the entry point allows only surround/repeat in VSCode
- `lua/cfg/standalone/theme.lua` — colorscheme default + local persistence (`~/.local/state/nvim/user-theme`)
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
- `lua/cfg/oil.lua` — filesystem editing (`<leader>fE`); browsing uses Snacks explorer
- `lua/cfg/guess-indent.lua` — detect existing file indentation while respecting EditorConfig
- `lua/cfg/snacks.lua` — picker/explorer, terminal, notifier, Git UI, image rendering and editing UI helpers
- `lua/cfg/dependencies.lua` — external tool declarations and one startup summary for missing everyday dependencies
- `lua/cfg/health.lua` — `:checkhealth cfg`: tool paths, requirements, Nix setup, language tools and terminal image capability
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

- Shared `cfg.core` loads first; `vim.g.vscode` selects `cfg.vscode` or `cfg.standalone`, then lazy loads the plugin inventory. Core has no plugin dependencies.
- VSCode uses a plugin whitelist through lazy `cond`, retaining disabled plugins for standalone use. Specs must not trigger standalone services while being evaluated; explicit plugin `cond` functions must also respect the host.
- VSCode/VSCodium setup, keybindings and verification: [docs/vscode.md](docs/vscode.md).
- Everything under `cfg.` namespace — prevents require() shadowing plugins
- One spec per file — add/remove = add/delete a file
- LSP servers are declared once in `lua/cfg/lsp/servers.lua`; project, system and Mason binaries are all supported
- Native `vim.lsp.config()` / `vim.lsp.enable()` owns runtime LSP setup
- Formatter tools are declared once in `lua/cfg/format/tools.lua`
- Mason appends its bin directory to `PATH`. `:MasonToolsInstall` explicitly installs tools found missing at startup; normal startup does not install tools or load the Mason LSP registry integration
- Tools already in `PATH` take precedence over Mason-installed tools
- Missing LSP servers are enabled when the explicit installer finishes. After adding tools through Nix or changing a project environment, restart Neovim from that environment
- Formatter configuration lives under `lua/cfg/format/`
- Themes: choose with `<leader>uC` (Snacks picker, live preview); preview never saves, cancellation restores the original theme/background, confirmation persists. `:colorscheme` also persists to the state dir. `default` in `cfg/standalone/theme.lua` is the factory fallback. Themes own all colors and backgrounds; there is no transparency toggle or highlight override.
- LSP keymaps: 0.12 built-ins stay authoritative (`gr*` family, `K`, `<C-s>`, `gO`); this config only adds `gd`/`gD`, `<leader>cd` (diagnostics float), `<leader>uh` (inlay hints), `<leader>cr` (`:lsp restart`)
- Leader layout and migration table: [docs/keymaps.md](docs/keymaps.md). `f` files/projects, `s` search/pick, `b` buffers/scratch, `c` code, `g` Git, `h` Git hunks, `u` UI, `n` messages/notifications, `t` terminals, `q` quit/sessions.
- Navigation: Snacks floating pickers — `ff` files, `fe` directory tree, `bb` buffers, `ss` document symbols, `sS` workspace symbols, `sd` diagnostics, `sD` buffer diagnostics (all with `<leader>`); file/symbol selection closes the picker
- File operations: `<leader>fE` edits the current file's directory with Oil; references use native `grr`; terminal toggles with `<C-/>`; notifications use `<leader>nh`/`nd`
- Explorer (`<leader>fe`): `l`/Enter expand directories or open files in Neovim; `h` collapses a directory, Backspace goes up, and `o` opens with a system application (Snacks defaults).
- Editing: indentation follows EditorConfig or file detection; C/C++ project clang-format settings take precedence when available. Resolution runs asynchronously; duplicate opening events are coalesced and stale results never override later edits or manual indentation. Without a project style, existing indentation is preserved; new C/C++ files use LLVM's default when clang-format is available. `:SetIndent [space|tab] <width>` overrides editing indentation for the current buffer; `:lua vim.b.manual_indent = nil` restores automatic detection on the next read/format.
- Formatting is manual via `<leader>cf` (buffer or visual selection), using configured formatters with LSP fallback. Saving never formats; there are no autoformat toggles. After successful formatting, editing indentation is re-detected from the output unless `:SetIndent` pinned it. Manual formatting still uses formatter rules, which may differ from a pinned editing width. `<leader>w` saves, `<leader>qq` quits all; native `<C-w>q` closes a window
- `<leader>s` groups search and selection (`sg` grep, `sr` grug-far, `sw`/`sb`/`sv` replacement prefill, `st` TODOs, plus symbols/diagnostics/help); `<leader>q` groups quit/sessions (`qq` quit, `qs` load, `qS` select, `ql` last, `qd` stop saving sessions)
- Markdown: Neovim stays in highlighted source view; `<leader>cp` starts/stops the browser preview at `localhost:8080`
- Filetypes: `.cu` uses the `cuda` parser; `.v`/`.vh` reuse `systemverilog` via `vim.treesitter.language.register`
- `lua/cfg/treesitter.lua`'s `ensure_installed` is the single source of truth for parsers — install missing ones explicitly with `:TSInstallConfigured`; reopen affected buffers after installation

## Tool setup and checks

- Start with `:checkhealth cfg` in your actual terminal/project environment. See [docs/dependencies.md](docs/dependencies.md) for the dependency policy and setup; normal UI startup summarizes missing everyday tools once. Requires Neovim 0.12+ with the locked Tree-sitter version.
- Ownership boundaries and maintenance checks: [docs/maintenance.md](docs/maintenance.md). Snacks and alternatives: [docs/snacks-review.md](docs/snacks-review.md).
- Search requires `rg` (ripgrep) on Neovim's `PATH`; file finding uses `fd`/`fdfind`, then `rg`, then `find`. Mason does not install these UI tools. For a temporary environment: `nix shell nixpkgs#ripgrep nixpkgs#fd -c nvim`.
- Blink uses its Lua matcher; completion does not download or compile a native matcher.
- Prefer the project's `nix develop` environment or Nix-provided executables. Existing `PATH` tools take precedence; Mason is an optional fallback, not a second mandatory installation.
- Run `:MasonToolsInstall` to install the configured missing LSP/formatter tools, or `:LspInstall <server>` for one server. Use `:Mason` to inspect installed packages. Tools without a Mason-managed source (such as `nixfmt`, `gofmt`, and `rustfmt`) still come from Nix/the language toolchain.
- Run `:TSInstallConfigured` to install missing parsers, and `:TSUpdate` when explicitly updating them. Plugin builds may also run `:TSUpdate`.
- In an affected project file, use `:checkhealth vim.lsp`, `:lua vim.print(vim.lsp.get_clients({bufnr = 0}))`, `:ConformInfo`, and `:checkhealth blink.cmp` to inspect attachment, roots, tools and completion.
- nil's `nix.flake.autoArchive = false` disables fetching/prompting for missing flake inputs. Run `nix flake archive` manually when dependency-aware Nix completion is needed.
- Folding starts expanded; returning to a window does not reset the user's fold level. `vim.print` retains its native behavior; use `Snacks.debug.inspect(...)` explicitly for Snacks debug output.
