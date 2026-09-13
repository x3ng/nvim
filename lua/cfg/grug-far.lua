-- Project-wide search & replace with a live diff buffer (snacks only searches).
-- Needs ripgrep on PATH (present via nix profile).
return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  keys = {
    {
      "<leader>sr",
      function() require("grug-far").open() end,
      desc = "Search & Replace (project)",
    },
    {
      "<leader>sw",
      function()
        require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
      end,
      desc = "Search & Replace (word)",
    },
    {
      "<leader>sb",
      function()
        require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
      end,
      desc = "Search & Replace (buffer)",
    },
    {
      "<leader>sv",
      mode = "x",
      function() require("grug-far").with_visual_selection() end,
      desc = "Search & Replace (selection)",
    },
  },
  opts = {},
}
