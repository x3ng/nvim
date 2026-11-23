-- Installation sources; formatter behavior is declared in formatters.lua.
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
