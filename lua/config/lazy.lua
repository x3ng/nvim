local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local vscode = not not vim.g.vscode
local shared_plugins = { ["lazy.nvim"] = true, ["nvim-surround"] = true, ["vim-repeat"] = true }
require("lazy").setup({ { import = "plugins" } }, {
  defaults = {
    -- Keep Neovim specs installed when using VSCode; Lazy clean is safe.
    cond = function(plugin)
      return not vscode or shared_plugins[plugin.name] == true
    end,
  },
  checker = { enabled = false },
  change_detection = { enabled = not vscode },
})
