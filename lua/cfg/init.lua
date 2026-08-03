require("cfg.core")
require("cfg.lsp")
require("cfg.lazy-nvim")

require("lazy").setup({
  { import = "cfg.transparent" },
  { import = "cfg.themery" },
  { import = "cfg.neo-tree" },
  { import = "cfg.blink-cmp" },
  { import = "cfg.telescope" },
  { import = "cfg.which-key" },
  { import = "cfg.flash" },
  { import = "cfg.fcitx" },
  { import = "cfg.bufferline" },
  { import = "cfg.render-markdown" },
  { import = "cfg.mason" },
  { import = "cfg.format.conform" },
  { import = "cfg.lsp.trouble" },
  { import = "cfg.lsp.fidget" },
})
