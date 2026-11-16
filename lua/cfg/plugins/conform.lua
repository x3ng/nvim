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
    formatters_by_ft = require("cfg.format.formatters"),
    default_format_opts = { lsp_format = "fallback" },
  },
}
