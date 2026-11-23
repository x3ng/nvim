# VSCode / VSCodium

Use the **VSCode Neovim** extension (`asvetliakov.vscode-neovim`), not VSCodeVim.
Both VSCode and VSCodium use the same host branch. Running `nvim` in an integrated
terminal still uses the full Neovim configuration.

## Setup

1. Install/enable VSCode Neovim in the editor you use. Disable VSCodeVim if present.
2. Merge [settings.json](vscode/settings.json) into your editor's **User Settings
   (JSON)**. Paths match this NixOS machine; adjust them for another machine or
   a remote extension host. Keep `neovimClean` false so this configuration loads.
3. Reload the editor window. In its Neovim command line, `:lua print(vim.g.vscode)`
   should print a truthy value. `:Lazy` should show only lazy, nvim-surround and
   vim-repeat as active plugins.

The settings JSON is a mergeable example, not automatically applied settings.
Existing VSCode/VSCodium user settings are not overwritten by this repository.

## Ownership

`config` contains leader, search preferences, basic editing keys and filetypes.
`config` also owns native UI, file watching, undo files, indentation, theme,
copy-location, Git review, LSP and formatting. `config.vscode` is the VSCode
branch and owns command bridges.

In VSCode, indentation/EditorConfig, diagnostics, language servers, completion,
auto-pairs, commenting, highlighting, folding, Git UI, terminal and formatting
come from VSCode and its extensions. Configure your language tooling there.
`:SetIndent` and automatic clang-format indentation discovery are Neovim-only.
Saving does not invoke a formatter from this Neovim configuration; VSCode's own
`editor.formatOnSave` setting remains authoritative.

The full lazy inventory is read in both hosts. A `cond` whitelist prevents
Neovim plugins from running without marking them for removal by `:Lazy clean`.
Plugin specs only declare configuration; reading them does not initialize native LSP.
Neovim services are started explicitly by `config.start()` after lazy setup.
Only nvim-surround and vim-repeat are shared editing plugins for now. Flash,
Tree-sitter textobjects are not enabled in VSCode.

## Keys

The leader is Space. The shared grouping and migration table are in
[keymaps.md](keymaps.md). VSCode commands replace these familiar operations:

| Keys | VSCode operation |
| --- | --- |
| `<leader>w`, `<leader>fn`, `<leader>bd` | Save, new untitled file, close editor |
| `<leader>qq` | Close the VSCode window (normal unsaved-change prompts apply) |
| `[b`, `]b`, Ctrl-h/j/k/l | Previous/next editor, navigate editor groups |
| `<leader>ff`, `fe`, `bb`, `sg`, `sc` | Quick Open, Explorer, editors, search, command palette |
| `<leader>fr` | Recent files/workspaces |
| `<leader>ss`, `sS`, `sd`, `sk` | Document/workspace symbols, Problems, keyboard shortcuts |
| `<leader>sr` | Replace in files |
| `<leader>cf` | Format document; in Visual mode, format selection |
| `gd`, `gD`, `grr`, `gri`, `grt` | Definition, declaration, references, implementation, type definition |
| `grn`, `gra`, `grx`, `gO`, `K` | Rename, quick fix, code lens, symbols, hover |
| `[d`, `]d`, `<leader>cd` | Previous/next diagnostic, hover with diagnostics |
| `<leader>uw`, `ul`, `uc`, `uC`, `uh` | Wrap, relative numbers, line highlight, theme, inlay hints |
| Ctrl-/, `<leader>gs`, `<leader>cp` | Terminal, source control, Markdown preview |

Number, line-highlight and inlay-hint toggles update global VSCode settings; more specific
workspace/language overrides may take precedence. Neovim-only features such as
theme selection, Oil directory editing, session management and picker-specific
keys have no host mapping. Native extension mappings handle other Vim operations.

Normal-mode Ctrl keys above are forwarded by the extension's default settings.
Custom VSCode shortcuts can intercept them: check Keyboard Shortcuts if a key does
not reach Neovim. This configuration does not add Insert or command-line Readline
mappings. If you previously copied the old `docs/vscode/keybindings.json` example,
remove those Insert-mode cursor/deletion overrides from your User Keyboard Shortcuts
to restore host defaults; repository changes do not edit your VSCode user settings.

## Verification

With the plugins already installed, run from this repository:

```sh
XDG_CACHE_HOME=/tmp/nvim-host-check/cache XDG_STATE_HOME=/tmp/nvim-host-check/state \
  nvim --headless -i NONE '+luafile tests/hosts.lua'
XDG_CACHE_HOME=/tmp/nvim-host-check/cache XDG_STATE_HOME=/tmp/nvim-host-check/state \
  nvim --headless -i NONE --cmd 'let g:vscode = v:true' '+luafile tests/hosts.lua'
```

These check startup, host isolation, lazy's cleanup protection, command dispatch
with a stub VSCode API, and actual surround editing. They do not replace a live
extension check. In VSCode/VSCodium, verify Quick Open, group navigation, selected
text formatting, surround, undo/redo and Insert shortcuts on a disposable file.

## References

- [vscode-neovim configuration and API](https://github.com/vscode-neovim/vscode-neovim#neovim-configuration):
  host detection, `vscode.action`, implicit Visual ranges, clipboard and key forwarding.
- [LazyVim VSCode implementation](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/vscode.lua):
  plugin whitelist through `defaults.cond` and editor command bridges. This config
  uses a smaller whitelist and does not depend on LazyVim.
