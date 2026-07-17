require("cfg.core")
require("cfg.lsp")
require("cfg.lazy-nvim")

require("lazy").setup({
  { import = "cfg.themery" },
  { import = "cfg.neo-tree" },
  { import = "cfg.blink-cmp" },
  { import = "cfg.telescope" },
  { import = "cfg.which-key" },
  { import = "cfg.flash" },
  { import = "cfg.bufferline" },
  { import = "cfg.render-markdown" },
  { import = "cfg.lsp.mason" },
  { import = "cfg.lsp.conform" },
  { import = "cfg.lsp.trouble" },
  { import = "cfg.lsp.fidget" },
})
