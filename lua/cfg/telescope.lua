return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.55,
        },
      },
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
          ["<C-d>"] = "delete_buffer",
          ["<ESC>"] = "close",
        },
      },
      prompt_prefix = "",
      selection_caret = " ",
    },
    pickers = {
      buffers = {          -- 缓冲区切换配置
        show_all_buffers = true,
        sort_lastused = true,
        theme = "dropdown",
        previewer = false,
      },
      find_files = {       -- 文件查找配置
        hidden = true,
        no_ignore = true,
      },
    },
  },  

  config = function(_, opts)
    require("telescope").setup(opts)
    
    local map_opts = { noremap = true, silent = true }
    local keymap = vim.keymap.set
    
    keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>",
      vim.tbl_extend("force", map_opts, { desc = "Find files" })
    )
    keymap("n", "<leader>fb", "<cmd>Telescope buffers<CR>",
      vim.tbl_extend("force", map_opts, { desc = "Find buffers" })
    )
    keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",
      vim.tbl_extend("force", map_opts, { desc = "Live grep" })
    )
  end,
}
