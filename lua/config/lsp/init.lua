local M = {}

-- Mason may not have appended its bin directory to PATH yet when LSP starts.
local function available(command)
  return vim.fn.executable(command) == 1
    or vim.fn.executable(vim.fn.stdpath("data") .. "/mason/bin/" .. command) == 1
end

-- A fresh query for installers; reading the registry never starts a server.
function M.missing()
  local missing = {}
  for name, config in pairs(require("config.lsp.servers")) do
    local command = config.cmd and config.cmd[1]
    if command and not available(command) then missing[#missing + 1] = name end
  end
  table.sort(missing)
  return missing
end

function M.setup()
  require("config.lsp.ui").setup()
  local missing = M.missing()
  for name, config in pairs(require("config.lsp.servers")) do
    vim.lsp.config(name, config)
    if not vim.list_contains(missing, name) then vim.lsp.enable(name) end
  end
end

return M
