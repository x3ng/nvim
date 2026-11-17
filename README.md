# nvim

## Structure

`init.lua` shows the startup order directly: shared settings → host settings →
bootstrap and plugin loading → standalone services. It does not delegate to a
second entry point.

```text
init.lua
lua/cfg/
├── bootstrap.lua          lazy.nvim bootstrap
├── core/                  shared options, editing keys and filetypes
├── standalone/            options, keymaps, autocmds and theme state
├── vscode/                host settings and VSCode command bridges
├── plugins/               lazy specs, automatically imported by directory
│   ├── snacks.lua
│   ├── conform.lua
│   ├── mason.lua
│   └── themes.lua         the four theme specs
├── lsp/                   setup(), UI behavior and server registry
├── format/                formatter registry, install sources and indentation
├── dependencies.lua       external tool declarations and availability queries
├── health.lua             startup summary and :checkhealth cfg
└── readline.lua           shared Insert/command-line editing
```

## Ownership and initialization

- `core`, `standalone` and `vscode` apply settings/keymaps when required by the entry point. `standalone` also explicitly registers builtin autocmds and the `:SetIndent` command.
- Plugin specs live only under `cfg/plugins/`. Reading a spec does not start services or probe tools; lazy invokes its `init`, `opts` and `config` callbacks at the appropriate stage. Related specs can share a file (themes and Mason).
- `cfg.lsp.setup()`, `cfg.format.cpp-indent.setup()`, theme setup/loading and `cfg.health.setup()` are called explicitly after `lazy.setup()`. Requiring a service module only exposes its functions.
- `cfg.lsp.servers` and `cfg.format.formatters` are configuration data shared by runtime, installation and health checks. Mason's specs query missing tools when loaded; queries do not initialize LSP.
- `cfg.dependencies` holds external tool declarations and PATH/Mason resolution. `cfg.health` owns reporting, installation-source checks and Snacks terminal capability integration. Startup dependency checks do not load Conform; an explicit health query loads it to inspect formatter commands.
- Noice owns message/notification routing, history and the command input overlay; Snacks renders notifications and the history picker. Routine messages expire after 2.5 seconds; errors, shell output and messages of 4+ lines stay in an unfocused split. `<leader>nh` opens unified message/notification history, `<leader>nd` dismisses both displays without clearing history. Notifications display at INFO and above.
- VSCode/VSCodium setup, keybindings and verification: [docs/vscode.md](docs/vscode.md).

## Conventions

- Shared `cfg.core` loads first; `vim.g.vscode` selects the host settings. Both hosts read the same plugin directory; only standalone starts native services after plugins load.
- VSCode uses a plugin whitelist through lazy `cond`, retaining disabled plugins for standalone use. Specs must not trigger standalone services while being evaluated; explicit plugin `cond` functions must also respect the host.
- Everything under `cfg.` namespace — prevents require() shadowing plugins
- Add/remove a plugin spec under `lua/cfg/plugins/`; there is no second manual import inventory. Keep runtime helpers outside this directory.
- LSP servers are declared once in `lua/cfg/lsp/servers.lua`; project, system and Mason binaries are all supported
- Native `vim.lsp.config()` / `vim.lsp.enable()` owns runtime LSP setup
- Formatter tools are declared once in `lua/cfg/format/tools.lua`
- Mason appends its bin directory to `PATH`. `:MasonToolsInstall` explicitly installs tools found missing when the installer loads; normal startup does not install tools or load the Mason LSP registry integration
- Tools already in `PATH` take precedence over Mason-installed tools
- Missing LSP servers are enabled when the explicit installer finishes. After adding tools through Nix or changing a project environment, restart Neovim from that environment
- Formatter selection lives in `lua/cfg/format/formatters.lua`, installation sources in `format/tools.lua`, and plugin behavior in `plugins/conform.lua`.
- Themes: choose with `<leader>uC` (Snacks picker, live preview); preview never saves, cancellation restores the original theme/background, confirmation persists. `:colorscheme` also persists to the state dir. `default` in `cfg/standalone/theme.lua` is the factory fallback. Themes own all colors and backgrounds; there is no transparency toggle or highlight override.
- LSP keymaps: 0.12 built-ins stay authoritative (`gr*` family, `K`, `<C-s>`, `gO`); this config only adds `gd`/`gD`, `<leader>cd` (diagnostics float), `<leader>uh` (inlay hints), `<leader>cr` (`:lsp restart`)
- Leader layout and migration table: [docs/keymaps.md](docs/keymaps.md). `f` files/projects, `s` search/pick, `b` buffers/scratch, `c` code, `g` Git, `h` Git hunks, `u` UI, `n` messages/notifications, `t` terminals, `q` quit/sessions.
- Navigation: Snacks floating pickers — `ff` files, `fe` directory tree, `bb` buffers, `ss` document symbols, `sS` workspace symbols, `sd` diagnostics, `sD` buffer diagnostics (all with `<leader>`); file/symbol selection closes the picker
- File operations: `<leader>fE` edits the current file's directory with Oil; references use native `grr`; terminal toggles with `<C-/>`; `th`/`tv` (with leader) move the same shell to a bottom/right split, and repeat to hide; messages and notifications use `<leader>nh`/`nd`
- Explorer (`<leader>fe`): `l`/Enter expand directories or open files in Neovim; `h` collapses a directory, Backspace goes up, and `o` opens with a system application (Snacks defaults).
- Editing: indentation follows EditorConfig or file detection; C/C++ project clang-format settings take precedence when available. Resolution runs asynchronously; duplicate opening events are coalesced and stale results never override later edits or manual indentation. Without a project style, existing indentation is preserved; new C/C++ files use LLVM's default when clang-format is available. `:SetIndent [space|tab] <width>` overrides editing indentation for the current buffer; `:lua vim.b.manual_indent = nil` restores automatic detection on the next read/format.
- Formatting is manual via `<leader>cf` (buffer or visual selection), using configured formatters with LSP fallback. Saving never formats; there are no autoformat toggles. After successful formatting, editing indentation is re-detected from the output unless `:SetIndent` pinned it. Manual formatting still uses formatter rules, which may differ from a pinned editing width. `<leader>w` saves, `<leader>qq` quits all; native `<C-w>q` closes a window
- `<leader>s` groups search and selection (`sg` grep, `sr` grug-far, `sw`/`sb`/`sv` replacement prefill, `st` TODOs, plus symbols/diagnostics/help); `<leader>q` groups quit/sessions (`qq` quit, `qs` load, `qS` select, `ql` last, `qd` stop saving sessions)
- Markdown: Neovim stays in highlighted source view; `<leader>cp` starts/stops the browser preview at `localhost:8080`
- Filetypes: `.cu` uses the `cuda` parser; `.v`/`.vh` reuse `systemverilog` via `vim.treesitter.language.register`
- `lua/cfg/plugins/treesitter.lua`'s `ensure_installed` is the single source of truth for parsers — install missing ones explicitly with `:TSInstallConfigured`; reopen affected buffers after installation

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
