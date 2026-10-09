-- Overlay the bottom statusline while typing instead of reserving a command row.
-- Blink handles cmdline completion; Snacks renders notifications.
return {
  "folke/noice.nvim",
  lazy = false,
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    cmdline = { enabled = true, view = "cmdline" },
    messages = {
      view = "mini",
      view_error = "cmdline_output",
      view_warn = "notify",
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
        enter = false,
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
      cmdline_output = { format = { "{message}" }, enter = false },
      -- Only an explicit history command should move focus to messages.
      messages = { enter = true },
      mini = { timeout = 2500, focusable = false },
    },
    routes = {
      {
        filter = { event = "msg_show", error = true },
        view = "cmdline_output",
        opts = { merge = true, title = "Messages" },
      },
      -- Shell output stays readable even when delivered in short chunks.
      {
        filter = { event = "msg_show", kind = { "shell_out", "shell_err" } },
        view = "cmdline_output",
        opts = { merge = true, title = "Messages" },
      },
      -- Keep substantial output; routine editing/save reports use mini instead.
      {
        filter = {
          event = "msg_show",
          min_height = 4,
          ["not"] = {
            any = {
              { kind = { "confirm", "confirm_sub", "number_prompt", "return_prompt", "search_count" } },
              { error = true },
              { warning = true },
            },
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
  keys = {
    { "<leader>nm", "<cmd>Noice history<cr>", desc = "Editor Message History" },
    { "<leader>nc", "<cmd>Noice dismiss<cr>", desc = "Dismiss Editor Messages" },
  },
}
