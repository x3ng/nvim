-- Markdown: marksman
vim.lsp.config('marksman', {
  cmd = { 'marksman' },
  filetypes = { 'markdown' },
  root_markers = { '.marksman.toml', '.git' },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function() vim.lsp.enable('marksman') end,
})
