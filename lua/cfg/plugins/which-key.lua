return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 300,
    spec = {
      { "<leader>f", group = "Files & Projects" },
      { "<leader>s", group = "Search & Pick" },
      { "<leader>g", group = "Git" },
      { "<leader>c", group = "Code" },
      { "<leader>h", group = "Git Hunks" },
      { "<leader>t", group = "Terminal" },
      { "<leader>n", group = "Messages & Notifications" },
      { "<leader>u", group = "UI" },
      { "<leader>b", group = "Buffers & Scratch" },
      { "<leader>q", group = "Quit & Sessions" },
      { "]", group = "Next" },
      { "[", group = "Prev" },
      { "g", group = "Goto" },
      { "z", group = "Fold" },
    },
  },
}
