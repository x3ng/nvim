return {
  "neovim/nvim-lspconfig",
  -- Configure servers before the first buffer is read, without paying the cost
  -- at startup when no file is opened.
  event = { "BufReadPre", "BufNewFile" },
  config = function() require("config.lsp").setup() end,
}
