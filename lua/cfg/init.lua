require("cfg.core")
require("cfg.lsp")
require("cfg.lazy-vim")

require("lazy").setup({
  { import = "cfg.themery" },
  { import = "cfg.neo-tree" },
  { import = "cfg.blink-cmp" },
  { import = "cfg.telescope" },
  { import = "cfg.which-key" },
  { import = "cfg.bufferline" },
  { import = "cfg.lsp.mason" },
  { import = "cfg.lsp.conform" },
  { import = "cfg.lsp.trouble" },
  { import = "cfg.lsp.fidget" },
})
