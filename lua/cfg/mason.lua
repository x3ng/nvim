local lsp_servers = {}
local format_tools = require("cfg.format.tools")

for name, config in pairs(require("cfg.lsp.servers")) do
  if config.mason ~= false then
    table.insert(lsp_servers, name)
  end
end

table.sort(lsp_servers)

-- Guard against drift between what conform uses (cfg.format.conform) and what
-- mason installs (format_tools). Formatters outside this list are silently
-- unavailable on hosts without them otherwise.
local exceptions = {
  gofmt = "ships with the Go toolchain",
  goimports = "ships with the Go toolchain",
  ["verible-verilog-format"] = "installed via the LSP package 'verible'",
}

local used = {}
local ok, conform_spec = pcall(require, "cfg.format.conform")
if ok and type(conform_spec.opts) == "table" then
  for _, names in pairs(conform_spec.opts.formatters_by_ft or {}) do
    if type(names) == "table" then
      for _, n in ipairs(names) do
        if n ~= "stop_after_first" then used[n] = true end
      end
    elseif type(names) == "string" then
      used[names] = true
    end
  end
end

local unhandled = {}
for formatter in pairs(used) do
  if not vim.list_contains(format_tools, formatter) and not exceptions[formatter] then
    table.insert(unhandled, formatter)
  end
end

if #unhandled > 0 then
  vim.schedule(function()
    vim.notify(
      "Formatters used by conform but not installed via mason:\n  "
        .. table.concat(unhandled, "\n  ")
        .. "\nAdd them to lua/cfg/format/tools.lua or document them as exceptions.",
      vim.log.levels.WARN,
      { title = "mason" }
    )
  end)
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
