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
          require("config.indent").after_format(buf)
        )
      end,
      mode = { "n", "v" },
      desc = "Format Buffer/Selection",
    },
  },
  opts = function()
    return {
      formatters_by_ft = require("config.format.formatters"),
      default_format_opts = { lsp_format = "fallback" },
    }
  end,
}
