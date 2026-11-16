require("cfg.core")
local vscode = not not vim.g.vscode
require(vscode and "cfg.vscode" or "cfg.standalone")
require("cfg.lazy-nvim")

local shared_plugins = { ["lazy.nvim"] = true, ["nvim-surround"] = true, ["vim-repeat"] = true }
require("lazy").setup(require("cfg.plugins"), {
  defaults = {
    cond = function(plugin)
      return not vscode or shared_plugins[plugin.name] == true
    end,
  },
  checker = { enabled = false },
  change_detection = { enabled = not vscode },
})

if not vscode then
  require("cfg.standalone.theme").load()
  require("cfg.dependencies").setup()
end
