return {
  "neovim/nvim-lspconfig",
  -- Configure servers before the first buffer is read, without paying the cost
  -- at startup when no file is opened.
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("config.lsp.ui").setup()
    local available = require("config.executable")
    for name, config in pairs(require("config.lsp.servers")) do
      vim.lsp.config(name, config)
      if available(config.cmd[1]) then vim.lsp.enable(name) end
    end
  end,
}
