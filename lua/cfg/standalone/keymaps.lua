-- ── Buffer navigation ────────────────────────────────────────────────────────
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "[b", "<cmd>bprev<CR>", { desc = "Prev buffer", silent = true })

-- ── Window navigation ────────────────────────────────────────────────────────
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left", silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down", silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up", silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right", silent = true })


-- ── Basic editing ────────────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save", silent = true })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All", silent = true })
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File", silent = true })

-- ── UI toggles ───────────────────────────────────────────────────────────────
-- `<leader>uh` (inlay hints) belongs to the LSP layer; see cfg/lsp/lsp-config.lua
vim.keymap.set("n", "<leader>uw", function() vim.wo.wrap = not vim.wo.wrap end, { desc = "Toggle Wrap" })
vim.keymap.set("n", "<leader>ul", function() vim.wo.relativenumber = not vim.wo.relativenumber end, { desc = "Toggle Relative Number" })
vim.keymap.set("n", "<leader>uc", function() vim.wo.cursorline = not vim.wo.cursorline end, { desc = "Toggle Cursorline" })
