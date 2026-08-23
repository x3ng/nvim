return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      globalstatus = true,
      component_separators = "",
      section_separators = "",
      disabled_filetypes = { statusline = { "dashboard", "alpha", "oil", "snacks_dashboard" } },
      theme = "auto",
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "diagnostics" },
      lualine_c = {
        { "filename", path = 1, symbols = { modified = "●", readonly = "🔒", unnamed = "[No Name]" } },
      },
      lualine_x = {},
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { "location" },
    },
    extensions = { "oil", "lazy", "mason" },
  },
}