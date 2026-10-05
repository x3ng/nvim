return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 300,
    spec = {
      { "<leader>f", group = "Find/Search" },
      { "<leader>s", group = "Search & Replace" },
      { "<leader>g", group = "Git" },
      { "<leader>c", group = "Code/LSP" },
      { "<leader>h", group = "Hunk (Git)" },
      { "<leader>t", group = "Terminal" },
      { "<leader>n", group = "Notifications" },
      { "<leader>u", group = "UI Toggle" },
      { "<leader>b", group = "Buffer" },
      { "<leader>q", group = "Quit/Session" },
      { "]", group = "Next" },
      { "[", group = "Prev" },
      { "g", group = "Goto" },
      { "z", group = "Fold" },
    },
  },
}
