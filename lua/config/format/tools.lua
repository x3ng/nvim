-- Mason package names for formatter and parser tooling; selection lives in formatters.lua.
return {
  packages = {
    "black",
    "isort",
    "markdownlint",
    "prettier",
    "prettierd",
    "stylua",
    "fourmolu",
    "goimports",
    "tree-sitter-cli",
  },
  commands = { ["tree-sitter-cli"] = "tree-sitter" },
}
