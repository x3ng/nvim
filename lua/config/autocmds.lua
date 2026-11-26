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

  local group = vim.api.nvim_create_augroup("UserEditing", { clear = true })

  -- +line arguments and picker jumps move the cursor afterwards and still win.
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    desc = "Restore the last cursor position",
    callback = function(ev)
      local bo = vim.bo[ev.buf]
      if bo.buftype ~= "" or bo.filetype == "gitcommit" or vim.api.nvim_get_current_buf() ~= ev.buf then return end
      if not vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 1, 0 }) then return end
      local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
      if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "help", "qf", "checkhealth" },
    desc = "Close auxiliary windows with q",
    callback = function(ev)
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, desc = "Close Window", silent = true })
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    desc = "Create missing parent directories on save",
    callback = function(ev)
      if vim.bo[ev.buf].buftype ~= "" or ev.match:match("^%a[%w+.-]*://") then return end
      vim.fn.mkdir(vim.fn.fnamemodify(ev.match, ":p:h"), "p")
    end,
  })
end

return M
