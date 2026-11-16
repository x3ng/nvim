local format_tools = require("cfg.format.tools")
-- Specs are evaluated even when lazy's cond disables the plugin. Do not start
-- native language servers merely by reading the inventory inside VSCode.
local missing_lsp_servers = vim.g.vscode and {} or require("cfg.lsp")
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

local function available(bin)
  return vim.fn.executable(bin) == 1 or vim.uv.fs_stat(mason_bin .. "/" .. bin) ~= nil
end

local missing_format_tools = {}
for _, name in ipairs(format_tools) do
  local bin = name == "tree-sitter-cli" and "tree-sitter" or name
  if not available(bin) then table.insert(missing_format_tools, name) end
end

-- Nix/project executables take precedence; Mason is an explicit fallback.
-- mason-tool-installer accepts LSP names through mason-lspconfig integration.
local missing_tools = vim.list_extend(vim.deepcopy(missing_format_tools), missing_lsp_servers)

-- Guard against drift between what conform uses and what Mason installs.
-- Formatters supplied by Nix or a language toolchain are listed as exceptions.
local exceptions = {
  gofmt = "ships with the Go toolchain",
  nixfmt = "provided by the Nix configuration",
  rustfmt = "provided by the Rust toolchain",
  verible = "installed via the LSP package 'verible' (verible-verilog-format executable)",
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

if not vim.g.vscode and #unhandled > 0 then
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
    opts = {
      ensure_installed = {},
      automatic_enable = missing_lsp_servers,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    cmd = { "MasonToolsInstall", "MasonToolsInstallSync", "MasonToolsUpdate", "MasonToolsUpdateSync" },
    dependencies = { "williamboman/mason.nvim", "mason-org/mason-lspconfig.nvim" },
    opts = {
      ensure_installed = missing_tools,
      run_on_start = false,
    },
  },
}
