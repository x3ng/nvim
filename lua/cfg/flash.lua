return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    modes = {
      char = {
        jump_labels = true, -- f/t 增强：按 f + 字符后自动出 label
      },
    },
  },
  keys = {
    {
      "<leader>s",
      mode = { "n", "x", "o" },
      function() require("flash").jump() end,
      desc = "Flash jump",
    },
    {
      "S",
      mode = { "n", "x", "o" },
      function() require("flash").jump({
        search = { mode = function(str) return "\\<" .. str end },
      }) end,
      desc = "Flash jump (word start)",
    },
  },
}
