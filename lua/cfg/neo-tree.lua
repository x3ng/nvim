return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle NeoTree" },
    { "<leader>r", "<cmd>Neotree refresh<CR>", desc = "Refresh NeoTree" },
  },
  opts = {
    filesystem = {
      quit_on_open = false,
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      follow_current_file = { enabled = true },
      hijack_netrw_behavior = "open_default",
    },
    window = {
      width = 30,
      mappings = {
        ["<space>"] = "none",
        ["o"] = "open",
        ["<esc>"] = "close_window",
        ["dd"] = "delete",
        ["R"] = "rename",
      },
    },
    default_component_configs = {
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "",
        folder_empty_open = "",
      },
      modified = { symbol = "●" },
    },
  },
}
