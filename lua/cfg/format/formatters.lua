-- Conform formatter names by filetype; read by the plugin and health checks.
return {
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
}
