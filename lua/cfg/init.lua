-- Load order matters:
--   1. base    — leader keys and options must exist before anything maps to them
--   2. lsp     — registers vim.lsp.config/enable() early; runs BEFORE mason
--                extends PATH, hence the mason bin-dir probe in cfg/lsp/init.lua
--   3. lazy-nvim then hands off to lazy.setup() for all plugin specs
require("cfg.base")
require("cfg.lsp")
require("cfg.lazy-nvim")

require("lazy").setup({
  { import = "cfg.themes" },
  { import = "cfg.treesitter" },
  { import = "cfg.treesitter-context" },
  { import = "cfg.blink-cmp" },
  { import = "cfg.mini-pairs" },
  { import = "cfg.surround" },
  { import = "cfg.flash" },
  { import = "cfg.fcitx" },
  { import = "cfg.render-markdown" },
  { import = "cfg.mason" },
  { import = "cfg.format.conform" },
  { import = "cfg.lazydev" },
  { import = "cfg.gitsigns" },
  { import = "cfg.oil" },
  { import = "cfg.aerial" },
  { import = "cfg.snacks" },
  { import = "cfg.noice" },
  { import = "cfg.lualine" },
  { import = "cfg.which-key" },
  { import = "cfg.ts-comments" },
  { import = "cfg.todo-comments" },
  { import = "cfg.grug-far" },
  { import = "cfg.persistence" },
})
