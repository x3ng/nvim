return {
  {
    "zaldih/themery.nvim",
    priority = 1000,
    config = function()
      require("themery").setup({

        globalBefore = [[
          vim.cmd("hi clear")
          vim.cmd("syntax reset")
        ]],

        themes = {
          -- Catppuccin
          {
            name = "Catppuccin Mocha Dark",
            colorscheme = "catppuccin",
            before = [[
              require("catppuccin").setup({ flavour = "mocha" })
            ]],
          },
          {
            name = "Catppuccin Latte Light",
            colorscheme = "catppuccin",
            before = [[
              require("catppuccin").setup({ flavour = "latte" })
            ]],
          },
          -- Gruvbox
          {
            name = "Gruvbox Dark",
            colorscheme = "gruvbox",
            before = [[
              vim.opt.background = "dark"
            ]],
          },
          -- Tokyonight
          {
            name = "Tokyonight Moon",
            colorscheme = "tokyonight",
            before = [[
              require("tokyonight").setup({ style = "moon" })
            ]],
          },
        },
        livePreview = true,
      })
    end,
  },

  { "catppuccin/nvim", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "folke/tokyonight.nvim", lazy = true },
}

