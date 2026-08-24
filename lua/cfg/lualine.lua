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
      lualine_x = {
        {
          -- cmdheight=0 hides vim's native "recording @q" message; surface it
          -- here instead. Zero-width when not recording.
          function()
            local reg = vim.fn.reg_recording()
            return reg ~= "" and "REC @" .. reg or ""
          end,
          color = "WarningMsg", -- semantic hl group: stays correct across themes
        },
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    extensions = { "oil", "lazy", "mason" },
  },
}