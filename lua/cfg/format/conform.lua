return {
  "stevearc/conform.nvim",
  -- load on demand: format_on_save needs BufWritePre, the keymaps below pull it
  -- in on first use
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format Buffer/Selection",
    },
    {
      "<leader>uf",
      function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.notify("Autoformat (global) " .. (vim.g.disable_autoformat and "off" or "on"), vim.log.levels.INFO)
      end,
      desc = "Toggle Autoformat (global)",
    },
    {
      "<leader>uF",
      function()
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        vim.notify("Autoformat (buffer) " .. (vim.b.disable_autoformat and "off" or "on"), vim.log.levels.INFO)
      end,
      desc = "Toggle Autoformat (buffer)",
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
      go = { "goimports", "gofmt" },
      markdown = { "markdownlint" },
      verilog = { "verible-verilog-format" },
      systemverilog = { "verible-verilog-format" },
      -- c/cpp: clangd formats via lsp_format fallback below
    },
    -- applies to both <leader>cf and format_on_save
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
      local disable_file = vim.fs.find(".noformat", { path = vim.api.nvim_buf_get_name(bufnr), upward = true })[1]
      if disable_file then
        return
      end
      return { timeout_ms = 500 }
    end,
  },
}
