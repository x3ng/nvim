return {
  "stevearc/conform.nvim",
  -- Formatting is explicit; saving never loads or invokes a formatter.
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function() require("conform").format({ async = true }) end,
      mode = { "n", "v" },
      desc = "Format Buffer/Selection",
    },
  },
  opts = {
    default_format_opts = { lsp_format = "fallback" },
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      python = { "isort", "black" },
      haskell = { "fourmolu" },
      go = { "goimports", "gofmt", stop_after_first = true },
      nix = { "nixfmt" },
      rust = { "rustfmt" },
      markdown = { "markdownlint" },
      verilog = { "verible" },
      systemverilog = { "verible" },
      -- c/cpp: clangd formats via Conform's lsp_format fallback
    },
  },
}
