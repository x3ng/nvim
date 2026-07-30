return {
  "h-hg/fcitx.nvim",
  cond = function()
    return vim.fn.executable("fcitx5-remote") == 1
  end,
  lazy = false,
}
