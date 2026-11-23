-- Settings first: leader and shared options must exist before plugin setup.
require("config")
require("config.lazy")

-- Theme plugins load lazily, so restore the persisted colorscheme afterwards.
if not vim.g.vscode then
  require("config.theme").load()
end
