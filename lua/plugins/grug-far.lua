-- Project-wide search & replace with a live diff buffer (snacks only searches).
-- Needs ripgrep on PATH; provided by the project environment or Nix.
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
        local path = vim.api.nvim_buf_get_name(0)
        if path == "" or vim.bo.buftype ~= "" or path:match("^%a[%w+.-]*://") or vim.fn.isdirectory(path) == 1 then
          vim.notify("No file to search in this buffer", vim.log.levels.WARN)
          return
        end
        require("grug-far").open({ prefills = { paths = vim.fn.escape(path, " ") } })
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
