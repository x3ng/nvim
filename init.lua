-- Settings first: leader and shared options must exist before plugin setup.
require("config")
require("config.lazy")

-- Native services need plugin paths and Mason's PATH.
if not vim.g.vscode then
  require("config.start").setup()
end
