return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
      format = {
        cmdline = { pattern = "^:", icon = ":", lang = "vim" },
        search_down = { pattern = "^/", icon = "/", lang = "regex" },
        search_up = { pattern = "^%?", icon = "?", lang = "regex" },
        filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
        lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=" }, icon = "☾", lang = "lua" },
        help = { pattern = "^:%s*he?l?p?%s+", icon = "?" },
        input = { view = "cmdline_input", icon = "󰥻 " },
      },
    },
    messages = {
      enabled = true,
      view = "notify",
      view_error = "notify",
      view_warn = "notify",
      view_history = "messages",
      view_search = "virtualtext",
    },
    popupmenu = {
      enabled = true,
      backend = "nui",
      kind_icons = {},
    },
    notify = {
      enabled = true,
      view = "notify",
    },
    lsp = {
      progress = { enabled = true },
      hover = { enabled = true },
      signature = { enabled = true },
      message = { enabled = true },
      documentation = { view = "hover" },
    },
    views = {
      cmdline_popup = {
        position = { row = "50%", col = "50%" },
        size = { width = 60, height = "auto" },
        border = { style = "rounded" },
        win_options = { winhighlight = "Normal:Normal,FloatBorder:FloatBorder" },
      },
      notify = {
        position = { row = 1, col = "100%" },
        size = { width = 40, height = "auto" },
        border = { style = "rounded" },
        win_options = { winhighlight = "Normal:Normal,FloatBorder:FloatBorder" },
      },
    },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
}