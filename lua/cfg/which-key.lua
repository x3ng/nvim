return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 300,
    spec = {
      { "<leader>f", group = "Find/Search" },
      { "<leader>g", group = "Git" },
      { "<leader>x", group = "Diagnostics" },
      { "<leader>c", group = "Code/LSP" },
      { "<leader>h", group = "Hunk (Git)" },
      { "<leader>t", group = "Terminal/Tree" },
      { "<leader>u", group = "UI Toggle" },
      { "<leader>w", group = "Window/Buffer" },
      { "<leader>", group = "Flash/Scratch" },
      { "]", group = "Next" },
      { "[", group = "Prev" },
      { "g", group = "Goto" },
      { "z", group = "Fold" },
    },
  },
}