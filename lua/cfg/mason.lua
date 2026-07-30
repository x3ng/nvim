local lsp_servers = {}
local format_tools = require("cfg.format.tools")

for name, config in pairs(require("cfg.lsp.servers")) do
  if config.mason ~= false then
    table.insert(lsp_servers, name)
  end
end

table.sort(lsp_servers)

return {
  {
    "williamboman/mason.nvim",
    opts = {
      PATH = "append",
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = lsp_servers,
      automatic_enable = false,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = format_tools,
    },
  },
}
