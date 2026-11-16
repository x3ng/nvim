return {
  "h-hg/fcitx.nvim",
  cond = function()
    return not vim.g.vscode and vim.fn.executable("fcitx5-remote") == 1
  end,
  lazy = false,
}
