require("cfg.lsp.lsp-config")

-- `.v` is already mapped to verilog by vim.filetype; only the header extension
-- is missing (`.sv`/`.svh` resolve to systemverilog out of the box)
vim.filetype.add({
  extension = {
    vh = "verilog",
  },
})

local missing = {}
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
-- executable() alone isn't enough here: this runs before mason extends PATH,
-- so also probe mason's bin dir directly
local function installed(bin)
  return vim.fn.executable(bin) == 1 or vim.uv.fs_stat(mason_bin .. "/" .. bin) ~= nil
end

for name, config in pairs(require("cfg.lsp.servers")) do
  local lsp_config = vim.deepcopy(config)
  lsp_config.mason = nil

  vim.lsp.config(name, lsp_config)

  -- skip enable when the binary is absent (e.g. mason still installing on a
  -- fresh host); run `:MasonInstall <pkg>` or install it system-wide instead
  local bin = config.cmd and config.cmd[1]
  if bin and not installed(bin) then
    table.insert(missing, string.format("%s (%s)", name, bin))
  else
    vim.lsp.enable(name)
  end
end

if #missing > 0 then
  vim.defer_fn(function()
    vim.notify(
      "LSP servers not found:\n  " .. table.concat(missing, "\n  "),
      vim.log.levels.WARN,
      { title = "LSP" }
    )
  end, 2000)
end
