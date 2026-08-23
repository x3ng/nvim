require("cfg.core")
require("cfg.lsp")
require("cfg.lazy-nvim")

require("lazy").setup({
  { import = "cfg.transparent" },
  { import = "cfg.themery" },
  { import = "cfg.treesitter" },
  { import = "cfg.blink-cmp" },
  { import = "cfg.flash" },
  { import = "cfg.fcitx" },
  { import = "cfg.render-markdown" },
  { import = "cfg.mason" },
  { import = "cfg.format.conform" },
  { import = "cfg.lazydev" },
  { import = "cfg.gitsigns" },
  { import = "cfg.oil" },
  { import = "cfg.snacks" },
  { import = "cfg.lualine" },
  { import = "cfg.noice" },
  { import = "cfg.which-key" },
})
