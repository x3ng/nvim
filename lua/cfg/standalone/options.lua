-- ── Behaviour ────────────────────────────────────────────────────────────────
vim.opt.autoread = true -- reload files changed on disk (needs checktime, see below)
vim.opt.confirm = true -- ask to save instead of erroring on `:q` with unsaved changes
vim.opt.undofile = true -- persistent undo across sessions
vim.opt.updatetime = 250 -- faster CursorHold: gitsigns, diagnostics, hover
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

vim.api.nvim_create_user_command("SetIndent", function(opts)
  local args = opts.fargs
  local style = #args == 1 and "space" or args[1]
  local size = tonumber(args[#args])
  if #args > 2 or (style ~= "space" and style ~= "tab") or not size or size < 1 or size > 16 or size % 1 ~= 0 then
    vim.notify("Usage: SetIndent [space|tab] <width 1..16>", vim.log.levels.ERROR)
    return
  end
  vim.bo.shiftwidth = size
  vim.bo.tabstop = size
  vim.bo.softtabstop = -1 -- follow shiftwidth
  vim.bo.expandtab = style == "space"
  vim.b.manual_indent = true -- preserve this choice against automatic indent detection
end, {
  desc = "Set current buffer indent style and width",
  nargs = "+",
  complete = function() return { "2", "4", "8", "space", "tab" } end
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
vim.opt.shortmess:append("W") -- Quiet successful writes; write errors still show.

-- Reading/editing defaults (nvim's own defaults are still Vim-era here)
vim.opt.wrap = true -- soft-wrap instead of scrolling sideways (stable viewport)
vim.opt.linebreak = true -- break on word boundaries, not mid-word
vim.opt.breakindent = true -- wrapped continuation keeps the original indent
vim.opt.smoothscroll = true -- <C-d>/<C-u>/<C-f>/<C-b> move by screen line, not buffer line
vim.opt.scrolloff = 8 -- keep context around the cursor
vim.opt.sidescrolloff = 8 -- only kicks in when `wrap` is toggled off
vim.opt.splitkeep = "screen" -- text stays put when splitting/closing windows
vim.opt.foldlevel = 99 -- initially open folds; autocmds must not reset user changes
vim.opt.signcolumn = "yes" -- stable gutter: no layout shift when signs appear
vim.opt.pumheight = 12 -- completion menu height
vim.opt.winborder = "rounded" -- one place to set borders for all floating windows (0.11+)
vim.opt.fillchars:append({ eob = " ", diff = "╱" })


-- ── Yank highlight ───────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("UserYank", { clear = true }),
  desc = "Highlight yanked text",
  callback = function() vim.hl.on_yank() end,
})
