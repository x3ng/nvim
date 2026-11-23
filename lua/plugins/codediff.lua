return {
  "esmuellert/codediff.nvim",
  version = "^4",
  cmd = "CodeDiff",
  opts = {
    explorer = { width = 24 },
  },
  keys = {
    { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "Review Working Tree" },
    -- Leave the command line open for revision and path completion.
    { "<leader>gD", ":CodeDiff<Space>", desc = "Review Git Range" },
    { "<leader>gH", "<cmd>CodeDiff history %<cr>", desc = "Review File History" },
  },
}
