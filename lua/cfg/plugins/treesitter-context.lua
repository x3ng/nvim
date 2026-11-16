-- Sticky header: keeps the enclosing function/class visible while scrolling.
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "VeryLazy",
  keys = {
    {
      "<leader>us",
      function() require("treesitter-context").toggle() end,
      desc = "Toggle Sticky Context",
    },
  },
  opts = {
    max_lines = 3, -- cap for deeply nested contexts
    multiline_threshold = 1,
    mode = "cursor", -- scope under the cursor, not the window top
  },
}
