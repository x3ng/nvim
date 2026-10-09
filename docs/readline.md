# Emacs / Readline editing keys

These mappings apply to Insert and command-line input. Normal mode keeps Vim's
editing and window commands. No extra runtime or build step is required.

| Keys | Insert | Command line (`:`, `/`, `?`) |
| --- | --- | --- |
| Ctrl-a / Ctrl-e | Start / end of line | Start / end of command |
| Ctrl-b / Ctrl-f | Left / right | Left / right |
| Ctrl-n / Ctrl-p | Down / up | Next / previous history item |
| Ctrl-d | Delete next character | Delete next character |
| Ctrl-k | Delete to end of line | Delete to end of command |
| Alt-b / Alt-f | Move by Vim word | Move by whitespace-delimited WORD |
| Alt-d | Delete forward by Vim word | Delete to end of next WORD |
| Alt-Backspace / Alt-Ctrl-h | Delete previous word | Delete previous WORD |

Ctrl-h remains Backspace. Ctrl-w/u retain native Vim behavior; Insert Ctrl-u
deletes the current input segment and does not always delete to the line start.
Word operations do not segment Chinese text. Alt chords require terminal support.

Ctrl-[ is Neovim's native Esc equivalent. It leaves Insert or cancels the command
line. In Snacks picker/input dialogs, the first press returns to Normal and the
second closes the dialog.

Blink leaves these editing keys available. Tab/Shift-Tab select completion items;
Insert also retains Up/Down for completion selection.
Snacks picker input inherits text editing, while Ctrl-n/p select list items.
Its actions on Ctrl-a/b/d/f/k/u and Alt-d/f remain available in Normal.
Snacks `vim.ui.input` uses Ctrl-n/p for input history.
Other plugins may need adaptation when they define buffer-local mappings.
Terminal buffers use the shell's own Readline bindings.

Chinese input uses the system input method; `fcitx.nvim` loads only when
`fcitx5-remote` is available. This configuration does not install an internal IME.

Inspired by [tpope/vim-rsi](https://github.com/tpope/vim-rsi), with Ctrl-n/p
movement and Snacks integration adapted for this configuration.
