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
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-v>"] = "actions.select_vsplit",
      ["<C-x>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
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
    { "<leader>e", "<cmd>Oil<cr>", desc = "Oil (cwd)" },
    { "<leader>E", "<cmd>Oil .<cr>", desc = "Oil (file dir)" },
  },
}