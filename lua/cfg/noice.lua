-- Keep lualine visible while Noice renders command input and messages.
-- Blink handles cmdline completion; Snacks renders notifications.
return {
  "folke/noice.nvim",
  lazy = false,
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    cmdline = { enabled = true, view = "cmdline_popup" },
    views = {
      popup = {
        -- A percentage keeps breathing room when the terminal is narrow or resized.
        size = { width = "70%", max_height = 20, height = "auto" },
        border = { padding = { 0, 1 } },
        -- Noice's popup uses NormalFloat, which vscode.nvim colors gray.
        -- Match the editor background and keep a visible accent border.
        win_options = {
          winhighlight = { Normal = "Normal", FloatBorder = "NoiceCmdlinePopupBorder" },
        },
      },
    },
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
