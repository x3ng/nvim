return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      numbers = "ordinal",          -- 显示缓冲区序号
      close_command = "bdelete! %d",-- 关闭缓冲区命令
      right_mouse_command = "bdelete! %d",
      sort_by = "insert_at_end",    -- 按使用顺序排序
      show_buffer_icons = true,     -- 显示文件图标
      separator_style = "thin",     -- 分隔符样式
      highlights = {
        buffer_selected = {         -- 高亮当前缓冲区
          bold = true,
          italic = false,
        },
      },
    },
  },
  config = function(_, opts)
    local map_opts = { noremap = true, silent = true }
    local keymap = vim.keymap.set

    for i = 1, 9 do
      keymap(
        "n",
        "<leader>" .. i,
        "<cmd>BufferLineGoToBuffer " .. i .. "<CR>",
        vim.tbl_extend("force", map_opts, { desc = "Go to buffer " .. i })
      )
    end
  end,
}
