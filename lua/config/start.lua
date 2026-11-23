-- Services need plugin paths and Mason's PATH, so start after lazy.setup().
local M = {}

function M.setup()
  require("config.lsp").setup()
  require("config.format.cpp-indent").setup()
  local theme = require("config.theme")
  theme.setup()
  theme.load()
  require("config.health").setup()
end

return M
