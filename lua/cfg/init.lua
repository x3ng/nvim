-- Load order matters:
--   1. core    — leader keys and options must exist before anything maps to them
--   2. lsp     — registers vim.lsp.config/enable() early; runs BEFORE mason
--                extends PATH, hence the mason bin-dir probe in cfg/lsp/init.lua
--   3. lazy-nvim then hands off to lazy.setup() for all plugin specs
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
  { import = "cfg.which-key" },
  { import = "cfg.ts-comments" },
})
