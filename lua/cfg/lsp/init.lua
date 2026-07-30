require("cfg.lsp.lsp-config")

vim.filetype.add({
  extension = {
    v = "verilog",
  },
})

for name, config in pairs(require("cfg.lsp.servers")) do
  local lsp_config = vim.deepcopy(config)
  lsp_config.mason = nil

  vim.lsp.config(name, lsp_config)
  vim.lsp.enable(name)
end
