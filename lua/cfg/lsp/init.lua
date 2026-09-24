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
  vim.lsp.config(name, config)

  -- Use existing project/system/Mason binaries immediately. Mason installs
  -- missing servers after startup and enables them when installation finishes.
  local bin = config.cmd and config.cmd[1]
  if bin and not installed(bin) then
    table.insert(missing, name)
  else
    vim.lsp.enable(name)
  end
end

table.sort(missing)
return missing
