return {
  "stevearc/conform.nvim",
  -- Formatting is explicit; saving never loads or invokes a formatter.
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        local buf = vim.api.nvim_get_current_buf()
        require("conform").format(
          { buf = buf, async = true, lsp_format = "fallback" },
          require("cfg.format.indent").after_format(buf)
        )
      end,
      mode = { "n", "v" },
      desc = "Format Buffer/Selection",
    },
  },
  opts = {
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
      verilog = { "verible-verilog-format" },
      systemverilog = { "verible-verilog-format" },
      -- c/cpp: clangd formats via lsp_format fallback below
    },
    default_format_opts = { lsp_format = "fallback" },
  },
}
