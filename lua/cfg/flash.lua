return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    modes = {
      char = {
        jump_labels = true,
      },
    },
  },
  keys = {
    {
      "<leader><leader>",
      mode = { "n", "x", "o" },
      function() require("flash").jump() end,
      desc = "Flash Jump",
    },
    {
      "S",
      mode = { "n", "x", "o" },
      function() require("flash").jump({ search = { mode = function(str) return "\\<" .. str end } }) end,
      desc = "Flash Jump (word start)",
    },
  },
}