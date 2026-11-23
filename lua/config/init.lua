-- Shared settings first; then the branch that owns the current runtime.
require("config.options")
require("config.keymaps")
vim.filetype.add({ extension = { vh = "verilog" } })

if vim.g.vscode then
  require("config.vscode").setup()
else
  require("config.copy_location").setup()
  require("config.autocmds").setup()
  require("config.indent").setup()
  require("config.theme").setup()
end
