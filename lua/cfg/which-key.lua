return {
  "folke/which-key.nvim",
  opts = {
    defaults = {
      ["<leader>f"] = { name = "+file/find" },  -- <leader>f 分组：文件/查找
      ["<leader>b"] = { name = "+buffer" },     -- <leader>b 分组：缓冲区
    },
  },
}
