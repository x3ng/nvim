-- Add/change/delete surrounding pairs: ysiw) / cs"' / ds{ / S in visual mode.
-- vim-repeat makes `.` repeat the last surround operation.
return {
  "kylechui/nvim-surround",
  version = "*", -- plugin expects a released tag to be used
  event = "VeryLazy",
  dependencies = { "tpope/vim-repeat" },
  opts = {},
}
