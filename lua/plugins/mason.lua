-- Query tools only when the installer is loaded, never while importing specs.
local function missing_packages()
  local available = require("config.executable")
  local packages = {
    "black",
    "isort",
    "markdownlint",
    "prettier",
    "prettierd",
    "stylua",
    "fourmolu",
    "goimports",
    "tree-sitter-cli",
  }
  local missing = {}
  for _, name in ipairs(packages) do
    local command = name == "tree-sitter-cli" and "tree-sitter" or name
    if not available(command) then missing[#missing + 1] = name end
  end
  return missing
end

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
    cmd = { "LspInstall", "LspUninstall" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = function()
      return { ensure_installed = {}, automatic_enable = false }
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    cmd = { "MasonToolsInstall", "MasonToolsInstallSync", "MasonToolsUpdate", "MasonToolsUpdateSync" },
    dependencies = { "williamboman/mason.nvim" },
    opts = function()
      return { ensure_installed = missing_packages(), run_on_start = false }
    end,
  },
}
