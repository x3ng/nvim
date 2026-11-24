-- Shared preferences. Neovim-only options are guarded so vscode-neovim,
-- which owns UI, clipboard and indentation, does not apply them.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.timeoutlen = 300
vim.opt.jumpoptions = "stack"

-- ── Searching ────────────────────────────────────────────────────────────────
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

if not vim.g.vscode then
  -- ── Behaviour ──────────────────────────────────────────────────────────────
  vim.opt.autoread = true -- reload files changed on disk (needs checktime)
  vim.opt.confirm = true -- ask to save instead of erroring on `:q` with unsaved changes
  vim.opt.undofile = true -- persistent undo across sessions
  vim.opt.updatetime = 250 -- faster CursorHold: gitsigns, diagnostics, hover
  vim.opt.completeopt = { "menu", "menuone", "noselect" }
  vim.opt.mouse = "a" -- allow the mouse to be used in nvim

  if vim.fn.executable("wl-copy") == 1 or vim.fn.executable("xclip") == 1 or vim.fn.executable("xsel") == 1 then
    vim.opt.clipboard = "unnamedplus" -- use system clipboard when a provider is available
  end

  -- Tab / Indent
  vim.opt.tabstop = 4 -- number of visual spaces per TAB
  vim.opt.softtabstop = -1 -- Tab and Backspace follow the effective shiftwidth
  vim.opt.shiftwidth = 4 -- default width of one indentation level
  vim.opt.expandtab = true -- tabs are spaces, mainly because of Python

  -- ── UI ─────────────────────────────────────────────────────────────────────
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
end
