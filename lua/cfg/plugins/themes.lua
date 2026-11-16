-- Theme specs share opaque defaults; selection/persistence lives in cfg.standalone.theme.
return {
  {
    -- each flavour is its own colorscheme: catppuccin-mocha/-macchiato/-frappe/-latte
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {},
  },
  {
    -- light/dark follows 'background'
    "ellisonleao/gruvbox.nvim",
    lazy = true,
    opts = {},
  },
  {
    -- each style is its own colorscheme: tokyonight-storm/-moon/-night/-day
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {},
  },
  {
    "Mofiqul/vscode.nvim",
    lazy = true,
    opts = {
      style = "dark",
      transparent = false,
      italic_comments = true,
    },
  },
}
