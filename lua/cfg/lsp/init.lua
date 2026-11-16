local M = {}

-- A fresh query for installers; reading the registry never starts a server.
function M.missing()
  local missing = {}
  for name, config in pairs(require("cfg.lsp.servers")) do
    local command = config.cmd and config.cmd[1]
    if command and not require("cfg.dependencies").resolve(command, true) then missing[#missing + 1] = name end
  end
  table.sort(missing)
  return missing
end

function M.setup()
  require("cfg.lsp.ui").setup()
  local missing = M.missing()
  for name, config in pairs(require("cfg.lsp.servers")) do
    vim.lsp.config(name, config)
    if not vim.list_contains(missing, name) then vim.lsp.enable(name) end
  end
end

return M
