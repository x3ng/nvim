-- Highlight TODO/FIXME/HACK/... in comments + jump/pick them.
-- snacks has no todo source, so the picker is a pre-filled rg search.
return {
  "folke/todo-comments.nvim",
  event = "VeryLazy",
  keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev Todo Comment" },
    {
      "<leader>st",
      function()
        Snacks.picker.grep({ search = [[\b(FIXME|TODO|HACK|BUG|WARN|PERF|NOTE|TEST)\b]] })
      end,
      desc = "Todo Comments",
    },
  },
  opts = {},
}
