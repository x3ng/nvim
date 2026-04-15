return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    filesystem = {
      quit_on_open = false,          -- 打开文件不关闭文件树
      filtered_items = {
        visible = true,              -- 显示过滤的文件
        hide_dotfiles = false,       -- 显示隐藏文件
        hide_gitignored = false,     -- 显示.gitignore中的文件
      },
      follow_current_file = { enabled = true }, -- 自动跟踪当前文件
      hijack_netrw_behavior = "open_default",   -- 替代netrw
    },
    window = {
      width = 30,                    -- 文件树宽度
      mappings = {
        ["<space>"] = "none",        -- 取消空格默认行为
        ["o"] = "open",              -- o 打开文件/文件夹
        ["<esc>"] = "close_window",  -- ESC 关闭文件树
        ["dd"] = "delete",           -- dd 删除文件
        ["R"] = "rename",            -- R 重命名
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
  config = function(_, opts)
    require("neo-tree").setup(opts)
    
    local keymap = vim.keymap.set
    local map_opts = { noremap = true, silent = true }
    
    keymap("n", "<leader>e", "<cmd>Neotree toggle<CR>", 
      vim.tbl_extend("force", map_opts, { desc = "Toggle NeoTree" })
    )
    
    keymap("n", "<leader>r", "<cmd>Neotree refresh<CR>", 
      vim.tbl_extend("force", map_opts, { desc = "Refresh NeoTree" })
    )
  end,
}
