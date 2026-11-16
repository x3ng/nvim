-- Settings first: leader and host options must exist before plugin setup.
require("cfg.core")
local vscode = not not vim.g.vscode
require(vscode and "cfg.vscode" or "cfg.standalone")

require("cfg.bootstrap")
local shared_plugins = { ["lazy.nvim"] = true, ["nvim-surround"] = true, ["vim-repeat"] = true }
require("lazy").setup({ { import = "cfg.plugins" } }, {
  defaults = {
    -- Keep standalone specs installed when using VSCode; Lazy clean is safe.
    cond = function(plugin)
      return not vscode or shared_plugins[plugin.name] == true
    end,
  },
  checker = { enabled = false },
  change_detection = { enabled = not vscode },
})

-- Services start explicitly after plugin paths and Mason's PATH are ready.
if not vscode then
  require("cfg.lsp").setup()
  require("cfg.format.cpp-indent").setup()
  local theme = require("cfg.standalone.theme")
  theme.setup()
  theme.load()
  require("cfg.health").setup()
end
