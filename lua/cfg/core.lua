-- Hint: use `:h <option>` to figure out the meaning if needed
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.autoread = true -- auto-reload files changed externally
if vim.fn.executable("wl-copy") == 1 or vim.fn.executable("xclip") == 1 or vim.fn.executable("xsel") == 1 then
  vim.opt.clipboard = "unnamedplus" -- use system clipboard when a provider is available
end
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.mouse = 'a' -- allow the mouse to be used in nvim

-- Tab / Indent
vim.opt.tabstop = 4 -- number of visual spaces per TAB
vim.opt.softtabstop = 4 -- number of spaces in tab when editing
vim.opt.shiftwidth = 4 -- insert 4 spaces on a tab
vim.opt.expandtab = true -- tabs are spaces, mainly because of Python

local current_indent = 4

local function toggle_indent()
  current_indent = current_indent == 4 and 2 or 4
  vim.opt.shiftwidth = current_indent
  vim.opt.tabstop = current_indent
  vim.opt.softtabstop = current_indent
  vim.opt.expandtab = true
  vim.notify(string.format("toggle indent to %d ", current_indent), vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>ti", toggle_indent, { desc = "Toggle Indent (2/4)" })

vim.api.nvim_create_user_command("SetIndent", function(opts)
  local size = tonumber(opts.args)
  if not size then
    vim.notify("Please input a number", vim.log.levels.ERROR)
    return
  end
  current_indent = size
  vim.opt.shiftwidth = size
  vim.opt.tabstop = size
  vim.opt.softtabstop = size
  vim.opt.expandtab = true
  vim.notify(string.format("set indent to %d ", size), vim.log.levels.INFO)
end, {
  desc = "Set indent size",
  nargs = 1,
  complete = function() return { "2", "4", "8" } end
})

-- UI config
vim.opt.number = true -- show absolute number
vim.opt.relativenumber = true -- add numbers to each line on the left side
vim.opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
vim.opt.splitbelow = true -- open new vertical split bottom
vim.opt.splitright = true -- open new horizontal splits right
vim.opt.termguicolors = true -- enable 24-bit RGB color in the TUI

-- Searching
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Buffer navigation
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "[b", "<cmd>bprev<CR>", { desc = "Prev buffer", silent = true })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer", silent = true })

-- Inlay hints (Neovim 0.11+)
vim.lsp.inlay_hint.enable(true)
