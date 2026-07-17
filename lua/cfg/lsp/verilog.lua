-- Verilog/SystemVerilog: Verible
vim.filetype.add({
  extension = {
    v = "verilog",
  },
})

vim.lsp.config("verible", {
  cmd = { "verible-verilog-ls" },
  filetypes = { "verilog", "systemverilog" },
  root_markers = {
    "verible.filelist",
    ".rules.verible_lint",
    ".git",
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "verilog", "systemverilog" },
  callback = function() vim.lsp.enable("verible") end,
})
