-- VSCode owns UI, file watching, indentation, completion and language tools.
-- The extension supplies its clipboard provider and editor synchronization.
local M = {}

function M.setup()
  if vim.g.vscode_clipboard then vim.g.clipboard = vim.g.vscode_clipboard end
  vim.opt.clipboard = "unnamedplus"
  require("config.vscode.keymaps")
end

return M
