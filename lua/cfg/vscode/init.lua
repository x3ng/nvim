-- VSCode owns UI, file watching, indentation, completion and language tools.
-- The extension supplies its clipboard provider and editor synchronization.
if vim.g.vscode_clipboard then vim.g.clipboard = vim.g.vscode_clipboard end
vim.opt.clipboard = "unnamedplus"
require("cfg.vscode.keymaps")
