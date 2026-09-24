-- Keep lualine visible while Noice renders command input and messages.
-- Blink handles cmdline completion; Snacks renders notifications.
return {
  "folke/noice.nvim",
  lazy = false,
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    cmdline = { enabled = true, view = "cmdline_popup" },
    routes = {
      -- Render output from typed Ex commands, including :ls and :!, in one view.
      { filter = { event = "msg_show", cmdline = true }, view = "popup" },
    },
    notify = { enabled = false },
    popupmenu = { enabled = false },
    lsp = {
      progress = { enabled = false },
      hover = { enabled = false },
      signature = { enabled = false },
      message = { enabled = false },
    },
  },
}
