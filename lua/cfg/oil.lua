return {
  "stevearc/oil.nvim",
  opts = {
    default_file_explorer = false,
    columns = {
      "icon",
      "permissions",
      "size",
      "mtime",
    },
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name, _)
        return name == ".." or name == ".git"
      end,
    },
    win_options = {
      wrap = false,
      signcolumn = "no",
      cursorcolumn = false,
      foldcolumn = "0",
      spell = false,
      list = false,
      conceallevel = 3,
      concealcursor = "nvic",
    },
    use_default_keymaps = true,
    float = {
      padding = 2,
      max_width = 0.8,
      max_height = 0.8,
      border = "rounded",
      win_options = {
        winblend = 0,
      },
    },
  },
  keys = {
    { "<leader>ce", "<cmd>Oil<cr>", desc = "Edit Directory (Oil)" },
  },
}
