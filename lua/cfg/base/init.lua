-- Hint: use `:h <option>` to figure out the meaning if needed
-- This layer runs BEFORE any plugin is loaded, so it must stay plugin-free
-- (see README: "Conventions").
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ── Behaviour ────────────────────────────────────────────────────────────────
vim.opt.autoread = true -- reload files changed on disk (needs checktime, see below)
vim.opt.confirm = true -- ask to save instead of erroring on `:q` with unsaved changes
vim.opt.undofile = true -- persistent undo across sessions
vim.opt.updatetime = 250 -- faster CursorHold: gitsigns, diagnostics, hover
vim.opt.timeoutlen = 300 -- leader/which-key popup latency
vim.opt.jumpoptions = "stack" -- jumplist pushes a new entry per new jump
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.mouse = "a" -- allow the mouse to be used in nvim

if vim.fn.executable("wl-copy") == 1 or vim.fn.executable("xclip") == 1 or vim.fn.executable("xsel") == 1 then
  vim.opt.clipboard = "unnamedplus" -- use system clipboard when a provider is available
end

-- `autoread` only marks buffers as stale; without checktime nothing is reloaded
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("UserAutoRead", { clear = true }),
  desc = "Reload files changed outside of Neovim",
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
  end,
})

-- Tab / Indent
vim.opt.tabstop = 4 -- number of visual spaces per TAB
vim.opt.softtabstop = 4 -- number of spaces in tab when editing
vim.opt.shiftwidth = 4 -- insert 4 spaces on a tab
vim.opt.expandtab = true -- tabs are spaces, mainly because of Python

local current_indent = 4

local function apply_indent(size)
  current_indent = size
  vim.opt.shiftwidth = size
  vim.opt.tabstop = size
  vim.opt.softtabstop = size
  vim.opt.expandtab = true
end

local function toggle_indent()
  apply_indent(current_indent == 4 and 2 or 4)
  vim.notify(string.format("toggle indent to %d ", current_indent), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("SetIndent", function(opts)
  local size = tonumber(opts.args)
  if not size then
    vim.notify("Please input a number", vim.log.levels.ERROR)
    return
  end
  apply_indent(size)
  vim.notify(string.format("set indent to %d ", size), vim.log.levels.INFO)
end, {
  desc = "Set indent size",
  nargs = 1,
  complete = function() return { "2", "4", "8" } end
})

-- ── UI ───────────────────────────────────────────────────────────────────────
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

-- Reading/editing defaults (nvim's own defaults are still Vim-era here)
vim.opt.wrap = false -- code wraps visually and breaks `j`/`k`; `z`/`<leader>uw` when needed
vim.opt.scrolloff = 8 -- keep context around the cursor
vim.opt.sidescrolloff = 8
vim.opt.splitkeep = "screen" -- text stays put when splitting/closing windows
vim.opt.signcolumn = "yes" -- stable gutter: no layout shift when signs appear
vim.opt.pumheight = 12 -- completion menu height
vim.opt.winborder = "rounded" -- one place to set borders for all floating windows (0.11+)
vim.opt.fillchars:append({ eob = " ", diff = "╱" })

-- ── Searching ────────────────────────────────────────────────────────────────
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- ── Yank highlight ───────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("UserYank", { clear = true }),
  desc = "Highlight yanked text",
  callback = function() vim.hl.on_yank() end,
})

-- ── Buffer navigation ────────────────────────────────────────────────────────
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "[b", "<cmd>bprev<CR>", { desc = "Prev buffer", silent = true })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer", silent = true })

-- ── Window navigation ────────────────────────────────────────────────────────
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left", silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down", silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up", silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right", silent = true })

-- ── Basic editing ────────────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save", silent = true })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit", silent = true })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All", silent = true })
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File", silent = true })

-- ── UI toggles ───────────────────────────────────────────────────────────────
-- `<leader>uh` (inlay hints) belongs to the LSP layer; see cfg/lsp/lsp-config.lua
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear Highlight", silent = true })
vim.keymap.set("n", "<leader>uH", "<cmd>nohlsearch<cr>", { desc = "Clear Highlight", silent = true })
vim.keymap.set("n", "<leader>uw", function() vim.wo.wrap = not vim.wo.wrap end, { desc = "Toggle Wrap" })
vim.keymap.set("n", "<leader>ul", function() vim.wo.relativenumber = not vim.wo.relativenumber end, { desc = "Toggle Relative Number" })
vim.keymap.set("n", "<leader>uc", function() vim.wo.cursorline = not vim.wo.cursorline end, { desc = "Toggle Cursorline" })

-- Indent toggle
vim.keymap.set("n", "<leader>ti", toggle_indent, { desc = "Toggle Indent (2/4)" })

-- Theme selection, persistence and transparency
-- (`<leader>uC` for browsing colorschemes lives in cfg/snacks.lua: it needs a picker)
require("cfg.base.theme")
