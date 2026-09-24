local format_tools = require("cfg.format.tools")
local missing_lsp_servers = require("cfg.lsp")
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

local function available(bin)
  return vim.fn.executable(bin) == 1 or vim.uv.fs_stat(mason_bin .. "/" .. bin) ~= nil
end

local missing_format_tools = {}
for _, name in ipairs(format_tools) do
  local bin = name == "tree-sitter-cli" and "tree-sitter" or name
  if not available(bin) then table.insert(missing_format_tools, name) end
end

-- Guard against drift between what conform uses and what Mason installs.
-- Formatters supplied by Nix or a language toolchain are listed as exceptions.
local exceptions = {
  gofmt = "ships with the Go toolchain",
  goimports = "optional project tool; Mason requires Go to install it",
  nixfmt = "provided by the Nix configuration",
  rustfmt = "provided by the Rust toolchain",
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
      "Formatters used by conform without a managed source:\n  "
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
      ensure_installed = missing_lsp_servers,
      automatic_enable = missing_lsp_servers,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = missing_format_tools,
    },
  },
}
