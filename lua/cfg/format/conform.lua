return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      python = { "isort", "black" },
      haskell = { "fourmolu" },
      go = { "goimports", "gofmt" },
      markdown = { "markdownlint" },
      verilog = { "verible-verilog-format" },
      systemverilog = { "verible-verilog-format" },
      c = { "clangd" },
      cpp = { "clangd" },
    },
    format_on_save = function(bufnr)
      local disable_file = vim.fs.find(".noformat", { path = vim.api.nvim_buf_get_name(bufnr), upward = true })[1]
      if disable_file then
        return
      end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
  },
}
