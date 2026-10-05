-- Overlay the bottom statusline while typing instead of reserving a command row.
-- Blink handles cmdline completion; Snacks renders notifications.
return {
  "folke/noice.nvim",
  lazy = false,
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    cmdline = { enabled = true, view = "cmdline" },
    messages = {
      view = "cmdline_output",
      view_error = "cmdline_output",
      view_warn = "cmdline_output",
      view_history = "messages",
    },
    views = {
      cmdline = {
        position = { row = "100%", col = 0 },
        size = { width = "100%", height = 1 },
        border = { style = "none", padding = { 0, 0 } },
        win_options = { winblend = 0, wrap = false },
      },
      -- All output views inherit the editor's live theme groups.
      split = {
        size = "25%",
        enter = true,
        win_options = {
          winhighlight = {
            Normal = "Normal",
            NormalNC = "NormalNC",
            FloatBorder = "WinSeparator",
          },
        },
      },
      -- Shell output can arrive in chunks. Avoid repeating metadata/commands
      -- between chunks; keep the detailed format available in message history.
      cmdline_output = { format = { "{message}" } },
    },
    routes = {
      -- Use one route/options set for all output. Noice otherwise creates
      -- separate split instances for shell output and ordinary messages.
      {
        filter = {
          event = "msg_show",
          ["not"] = {
            kind = { "confirm", "confirm_sub", "number_prompt", "return_prompt", "search_count" },
          },
        },
        view = "cmdline_output",
        opts = { merge = true, title = "Messages" },
      },
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
