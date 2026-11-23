# nvim

## Structure

`init.lua` loads the shared configuration, then lazy.nvim, and starts native
services on the Neovim branch only. VSCode is a branch inside `lua/config/`,
not a parallel directory tree.

```text
init.lua
lua/
├── config/                 # first-party configuration
│   ├── init.lua            # shared settings + runtime branch
│   ├── options.lua         # shared options; native-only part guarded
│   ├── keymaps.lua         # shared keys; native-only part guarded
│   ├── autocmds.lua        # native-only autocmds
│   ├── lazy.lua            # lazy.nvim bootstrap and setup
│   ├── vscode/             # VSCode branch: settings and command bridges
│   ├── lsp/                # server registry, setup and UI
│   ├── format/             # formatter registry and install sources
│   ├── indent.lua          # :SetIndent and post-format indentation detection
│   ├── copy_location.lua   # gy / gY
│   └── theme.lua           # theme selection and persistence
└── plugins/                # lazy specs, automatically imported by directory
    ├── snacks.lua
    ├── conform.lua
    ├── mason.lua
    └── themes.lua          # the four theme specs
```

## Ownership and initialization

- `config` is first-party configuration; `plugins` contains third-party plugin declarations. lazy imports only `plugins`.
- `init.lua` loads `config`, then `config.lazy`, and restores the persisted theme only when `vim.g.vscode` is unset.
- `config/init.lua` loads shared options/keymaps, then selects the VSCode branch or the native branch. The native branch registers copy-location, autocmds, `:SetIndent` and theme setup.
- `config/options.lua` and `config/keymaps.lua` are shared; their native-only sections are guarded by `if not vim.g.vscode`. `config/autocmds.lua` is native-only.
- Plugin specs live only under `plugins/`. Reading a spec does not start services, probe tools or load `config.*`. Related specs can share a file (themes and Mason).
- `plugins/lsp.lua` triggers `config.lsp.setup()` on the first buffer (`BufReadPre` / `BufNewFile`), so startup does not initialize LSP unnecessarily. Theme loading runs after `lazy.setup()` on the native branch. Requiring a service module only exposes its functions.
- `config.lsp.servers` and `config.format.formatters` are configuration data shared by runtime, installation and tests. Mason's specs query missing tools when loaded; queries do not initialize LSP.
- External tools are not pre-checked or installed. Missing commands surface when their feature runs; use `:checkhealth vim.lsp`, `:ConformInfo` and `:Mason` to inspect installed tooling.
- Noice owns message/notification routing, history and the command input overlay; Snacks renders notifications and the history picker. Routine messages expire after 2.5 seconds; errors, shell output and messages of 4+ lines stay in an unfocused split. `<leader>nh` opens unified message/notification history, `<leader>nd` dismisses both displays without clearing history. Notifications display at INFO and above.
- VSCode/VSCodium setup, keybindings and verification: [docs/vscode.md](docs/vscode.md).

## Conventions

- Insert and command-line editing use native Neovim/Blink bindings without a Readline emulation layer. Blink uses its `enter` preset: Ctrl-n/p or Up/Down select, Enter accepts a selected candidate, Ctrl-e cancels, and Tab/Shift-Tab navigate snippet placeholders. Snacks uses its default input/picker bindings.

- `vim.g.vscode` selects the VSCode branch; everything else is the default Neovim configuration.
- VSCode uses a plugin whitelist through lazy `cond`, retaining disabled plugins for Neovim use. Specs must not trigger native modules while being evaluated.
- First-party code lives under `lua/config/`; specs live under `lua/plugins/` and are never required by first-party runtime code.
- Add/remove a plugin spec under `lua/plugins/`; there is no second manual import inventory. Keep runtime helpers outside this directory.
- LSP servers are declared once in `lua/config/lsp/servers.lua`; project, system and Mason binaries are all supported
- Native `vim.lsp.config()` / `vim.lsp.enable()` owns runtime LSP setup
- Formatter tools are declared once in `lua/config/format/tools.lua`
- Mason appends its bin directory to `PATH`. `:MasonToolsInstall` explicitly installs tools found missing when the installer loads; normal startup does not install tools or load the Mason LSP registry integration
- Tools already in `PATH` take precedence over Mason-installed tools
- Missing LSP servers are enabled when the explicit installer finishes. After adding tools through Nix or changing a project environment, restart Neovim from that environment
- Formatter selection lives in `lua/config/format/formatters.lua`, installation sources in `format/tools.lua`, and plugin behavior in `plugins/conform.lua`. `:SetIndent` and post-format re-detection live in `config/indent.lua`.
- Themes: choose with `<leader>uC` (Snacks picker, live preview); preview never saves, cancellation restores the original theme/background, confirmation persists. `:colorscheme` also persists to the state dir. `default` in `config/theme.lua` is the factory fallback. Themes own all colors and backgrounds; there is no transparency toggle or highlight override.
- LSP keymaps: 0.12 built-ins stay authoritative (`gr*` family, `K`, `<C-s>`, `gO`); this config only adds `gd`/`gD`, `<leader>cd` (diagnostics float), `<leader>uh` (inlay hints), `<leader>cr` (`:lsp restart`)
- Leader layout and migration table: [docs/keymaps.md](docs/keymaps.md). `f` files/projects, `s` search/pick, `b` buffers/scratch, `c` code, `g` Git, `h` Git hunks, `u` UI, `n` messages/notifications, `t` terminals, `q` quit/sessions.
- Navigation: Snacks floating pickers — `ff` files, `fe` directory tree, `bb` buffers, `ss` document symbols, `sS` workspace symbols, `sd` diagnostics, `sD` buffer diagnostics (all with `<leader>`); file/symbol selection closes the picker
- File operations: `<leader>fE` edits the current file's directory with Oil; references use native `grr`; terminal toggles with `<C-/>`; `th`/`tv` (with leader) move the same shell to a bottom/right split, and repeat to hide; messages and notifications use `<leader>nh`/`nd`
- Explorer (`<leader>fe`): `l`/Enter expand directories or open files in Neovim; `h` collapses a directory, Backspace goes up, and `o` opens with a system application (Snacks defaults).
- Editing: indentation follows EditorConfig, then existing-file detection (`guess-indent`), then the language's own `indentexpr`. Treesitter indent is used only when the language has an `indents` query. `:SetIndent [space|tab] <width>` overrides editing indentation for the current buffer; `:lua vim.b.manual_indent = nil` restores automatic detection on the next read/format. Formatting may still use clang-format through LSP/Conform, but it does not change editing indentation.
- Formatting is manual via `<leader>cf` (buffer or visual selection), using configured formatters with LSP fallback. Saving never formats; there are no autoformat toggles. After successful formatting, editing indentation is re-detected from the output unless `:SetIndent` pinned it. Manual formatting still uses formatter rules, which may differ from a pinned editing width. `<leader>w` saves, `<leader>qq` quits all; native `<C-w>q` closes a window
- `<leader>s` groups search and selection (`sg` grep, `sr` grug-far, `sw`/`sb`/`sv` replacement prefill, `st` TODOs, plus symbols/diagnostics/help); `<leader>q` groups quit/sessions (`qq` quit, `qs` load, `qS` select, `ql` last, `qd` stop saving sessions)
- Markdown: Neovim stays in highlighted source view; `<leader>cp` starts/stops the browser preview at `localhost:8080`
- Filetypes: `.cu` uses the `cuda` parser; `.v`/`.vh` reuse `systemverilog` via `vim.treesitter.language.register`
- `lua/plugins/treesitter.lua`'s `ensure_installed` is the single source of truth for parsers — install missing ones explicitly with `:TSInstallConfigured`; reopen affected buffers after installation

## Tool setup and checks

- Requires Neovim 0.12+ with the locked Tree-sitter version. External tools are not pre-checked or installed; missing commands surface when the feature runs. Use `:checkhealth vim.lsp`, `:ConformInfo` and `:Mason` when a tool is missing.
- Ownership boundaries and maintenance checks: [docs/maintenance.md](docs/maintenance.md). Snacks and alternatives: [docs/snacks-review.md](docs/snacks-review.md).
- Search requires `rg` (ripgrep) on Neovim's `PATH`; file finding uses `fd`/`fdfind`, then `rg`, then `find`. Mason does not install these UI tools. For a temporary environment: `nix shell nixpkgs#ripgrep nixpkgs#fd -c nvim`.
- Blink uses its Lua matcher; completion does not download or compile a native matcher.
- Prefer the project's `nix develop` environment or Nix-provided executables. Existing `PATH` tools take precedence; Mason is an optional fallback, not a second mandatory installation.
- Run `:MasonToolsInstall` to install the configured missing LSP/formatter tools, or `:LspInstall <server>` for one server. Use `:Mason` to inspect installed packages. Tools without a Mason-managed source (such as `nixfmt`, `gofmt`, and `rustfmt`) still come from Nix/the language toolchain.
- Run `:TSInstallConfigured` to install missing parsers, and `:TSUpdate` when explicitly updating them. Plugin builds may also run `:TSUpdate`.
- In an affected project file, use `:checkhealth vim.lsp`, `:lua vim.print(vim.lsp.get_clients({bufnr = 0}))`, `:ConformInfo`, and `:checkhealth blink.cmp` to inspect attachment, roots, tools and completion.
- nil's `nix.flake.autoArchive = false` disables fetching/prompting for missing flake inputs. Run `nix flake archive` manually when dependency-aware Nix completion is needed.
- Folding starts expanded; returning to a window does not reset the user's fold level. `vim.print` retains its native behavior; use `Snacks.debug.inspect(...)` explicitly for Snacks debug output.
