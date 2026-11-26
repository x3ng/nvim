return {
  "neovim/nvim-lspconfig",
  -- Configure servers before the first buffer is read, without paying the cost
  -- at startup when no file is opened.
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("config.lsp.ui").setup()
    local available = require("config.executable")
    for name, config in pairs(require("config.lsp.servers")) do
      local command = config.executable or config.cmd[1]
      config = vim.deepcopy(config)
      config.executable = nil
      if next(config) then vim.lsp.config(name, config) end
      if available(command) then vim.lsp.enable(name) end
    end
  end,
}
