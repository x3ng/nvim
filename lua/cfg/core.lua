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
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true

-- Radical space saving
vim.opt.cmdheight = 0
vim.opt.laststatus = 3
vim.opt.showtabline = 0
vim.opt.showmode = false

-- Searching
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Buffer navigation
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "[b", "<cmd>bprev<CR>", { desc = "Prev buffer", silent = true })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer", silent = true })

-- Basic editing
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save", silent = true })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit", silent = true })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All", silent = true })
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File", silent = true })

-- UI toggles
vim.keymap.set("n", "<leader>uh", "<cmd>nohlsearch<cr>", { desc = "Clear Highlight", silent = true })
vim.keymap.set("n", "<leader>uw", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "Toggle Wrap" })
vim.keymap.set("n", "<leader>ul", function() vim.opt.relativenumber = not vim.opt.relativenumber:get() end, { desc = "Toggle Relative Number" })
vim.keymap.set("n", "<leader>uc", function() vim.opt.cursorline = not vim.opt.cursorline:get() end, { desc = "Toggle Cursorline" })

-- Indent toggle
vim.keymap.set("n", "<leader>ti", toggle_indent, { desc = "Toggle Indent (2/4)" })
