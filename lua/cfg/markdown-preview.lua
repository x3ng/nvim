return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  ft = { "markdown" },
  build = "cd app && npm install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_port = "8080"
    vim.g.mkdp_auto_start = 0
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("UserMarkdownPreview", { clear = true }),
      pattern = "markdown",
      callback = function(event)
        vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", {
          buffer = event.buf,
          desc = "Toggle Markdown Browser Preview",
        })
      end,
      desc = "Set Markdown browser preview keymap",
    })
  end,
}
