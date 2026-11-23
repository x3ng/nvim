-- Query tools only when the installer is loaded, never while importing specs.
local function missing_tools()
  local tools = require("config.format.tools")
  local missing = require("config.lsp").missing()
  for _, name in ipairs(tools.packages) do
    if not require("config.dependencies").resolve(tools.commands[name] or name, true) then missing[#missing + 1] = name end
  end
  return missing
end

return {
  -- Server defaults must be available even when installation UI is not loaded.
  { "neovim/nvim-lspconfig", lazy = false },
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
    cmd = { "LspInstall", "LspUninstall" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = function()
      return { ensure_installed = {}, automatic_enable = require("config.lsp").missing() }
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    cmd = { "MasonToolsInstall", "MasonToolsInstallSync", "MasonToolsUpdate", "MasonToolsUpdateSync" },
    dependencies = { "williamboman/mason.nvim", "mason-org/mason-lspconfig.nvim" },
    opts = function()
      return { ensure_installed = missing_tools(), run_on_start = false }
    end,
  },
}
