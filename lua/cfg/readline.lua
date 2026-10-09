-- Shared Insert / command-line editing, inspired by tpope/vim-rsi.
local M = {}

function M.setup()
  for key, rhs in pairs({
    ["<C-a>"] = "<Home>", ["<C-e>"] = "<End>",
    ["<C-b>"] = "<Left>", ["<C-f>"] = "<Right>", ["<C-d>"] = "<Del>",
    ["<M-b>"] = "<S-Left>", ["<M-f>"] = "<S-Right>",
    ["<M-BS>"] = "<C-w>", ["<M-C-h>"] = "<C-w>",
  }) do
    vim.keymap.set({ "i", "c" }, key, rhs, { desc = "Readline: " .. rhs, silent = true })
  end
  for key, rhs in pairs({ ["<C-n>"] = "<Down>", ["<C-p>"] = "<Up>" }) do
    vim.keymap.set("i", key, rhs, { desc = "Readline: " .. rhs, silent = true })
    -- Native Ctrl-n/p recall unfiltered history in command-line mode.
    vim.keymap.set("c", key, key, { desc = "Readline: command history", silent = true })
  end
  for key, rhs in pairs({ ["<C-k>"] = "<C-o>D", ["<M-d>"] = "<C-o>dw" }) do
    vim.keymap.set("i", key, function()
      if vim.api.nvim_win_get_cursor(0)[2] >= #vim.api.nvim_get_current_line() then return "" end
      return rhs
    end, { expr = true, silent = true, desc = "Readline: " .. rhs })
  end
  local function delete_command_tail(word_only)
    local tail = vim.fn.getcmdline():sub(vim.fn.getcmdpos())
    if word_only then
      -- Delete from the caret, preserving any prefix of the current WORD.
      local word = vim.fn.matchstr(tail, [[^\s*\S\+]])
      if word ~= "" then tail = word end
    end
    -- getcmdpos() counts bytes, while each <Del> removes a Unicode character.
    return string.rep("<Del>", vim.fn.strchars(tail))
  end
  vim.keymap.set("c", "<C-k>", function() return delete_command_tail(false) end,
    { expr = true, silent = true, desc = "Readline: delete to end" })
  vim.keymap.set("c", "<M-d>", function() return delete_command_tail(true) end,
    { expr = true, silent = true, desc = "Readline: delete next word" })
end

return M
