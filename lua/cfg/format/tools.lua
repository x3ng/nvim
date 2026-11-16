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
  external = {
    gofmt = "ships with the Go toolchain",
    nixfmt = "provided by the Nix configuration",
    rustfmt = "provided by the Rust toolchain",
    verible = "installed via the LSP package verible (verible-verilog-format executable)",
  },
}
