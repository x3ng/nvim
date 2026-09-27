-- Persistent symbol outline. Open on demand; follow the active source window.
return {
  "stevearc/aerial.nvim",
  cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialInfo" },
  keys = {
    { "<leader>co", "<cmd>AerialToggle<cr>", desc = "Toggle Outline" },
  },
  opts = {
    attach_mode = "global",
    layout = {
      default_direction = "prefer_right",
      min_width = 20,
      max_width = { 40, 0.3 },
    },
    show_guides = true,
  },
}
