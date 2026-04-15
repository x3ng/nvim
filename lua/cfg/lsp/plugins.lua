return {
  -- Mason (语言服务器安装器)
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      ensure_installed = {
        "lua-language-server",
        "clangd",
        "pyright",
      },
    },
  },

  -- conform.nvim (格式化)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        python = { "black", "isort" },
        go = { "goimports", "gofmt" },
      },
      format_on_save = function(bufnr)
        local ignore_filetypes = { "sql", "java", "c", "cpp" }
        if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
          return
        end
        local disable_file = vim.fs.find(".noformat", { path = vim.api.nvim_buf_get_name(bufnr), upward = true })[1]
        if disable_file then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    },
  },

  -- Trouble (诊断列表)
  {
    "folke/trouble.nvim",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions/References/... (Trouble)" },
    },
  },

  -- Fidget (LSP 加载进度)
  {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
  },
}
