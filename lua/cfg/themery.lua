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
            name = "Catppuccin Mocha (Dark)",
            colorscheme = "catppuccin",
            before = [[
              vim.opt.background = "dark"
              require("catppuccin").setup({ flavour = "mocha" })
            ]],
          },
          {
            name = "Catppuccin Macchiato (Dark)",
            colorscheme = "catppuccin",
            before = [[
              vim.opt.background = "dark"
              require("catppuccin").setup({ flavour = "macchiato" })
            ]],
          },
          {
            name = "Catppuccin Frappe (Dark)",
            colorscheme = "catppuccin",
            before = [[
              vim.opt.background = "dark"
              require("catppuccin").setup({ flavour = "frappe" })
            ]],
          },
          {
            name = "Catppuccin Latte (Light)",
            colorscheme = "catppuccin",
            before = [[
              vim.opt.background = "light"
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
          {
            name = "Gruvbox Light",
            colorscheme = "gruvbox",
            before = [[
              vim.opt.background = "light"
            ]],
          },
          -- Tokyonight
          {
            name = "Tokyonight Storm (Dark)",
            colorscheme = "tokyonight",
            before = [[
              vim.opt.background = "dark"
              require("tokyonight").setup({ style = "storm" })
            ]],
          },
          {
            name = "Tokyonight Moon (Dark)",
            colorscheme = "tokyonight",
            before = [[
              vim.opt.background = "dark"
              require("tokyonight").setup({ style = "moon" })
            ]],
          },
          {
            name = "Tokyonight Night (Dark)",
            colorscheme = "tokyonight",
            before = [[
              vim.opt.background = "dark"
              require("tokyonight").setup({ style = "night" })
            ]],
          },
          {
            name = "Tokyonight Day (Light)",
            colorscheme = "tokyonight",
            before = [[
              vim.opt.background = "light"
              require("tokyonight").setup({ style = "day" })
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
