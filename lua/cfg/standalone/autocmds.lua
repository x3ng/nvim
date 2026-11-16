local M = {}

function M.setup()
  -- `autoread` only marks buffers as stale; without checktime nothing is reloaded
  vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = vim.api.nvim_create_augroup("UserAutoRead", { clear = true }),
    desc = "Reload files changed outside of Neovim",
    callback = function()
      if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
    end,
  })

  -- ── Yank highlight ───────────────────────────────────────────────────────────
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("UserYank", { clear = true }),
    desc = "Highlight yanked text",
    callback = function() vim.hl.on_yank() end,
  })
end

return M
