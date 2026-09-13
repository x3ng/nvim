-- Diagnostic display
vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  -- show the diagnostic in a float while jumping with ]d/[d
  jump = { float = true },
  -- no `float.border`: 'winborder' is set globally in cfg/base/init.lua
})

-- Inlay hints (Neovim 0.11+), on by default; <leader>uh toggles per buffer
vim.lsp.inlay_hint.enable(true)

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, desc = desc })
    end

    -- Neovim 0.12 maps these itself, so they are intentionally NOT redefined:
    --   K      hover                 (buffer-local, on attach)
    --   <C-s>  signature help        (insert mode, global)
    --   gO     document symbols      (global)
    --   gra grn grr gri grt grx      code action / rename / references /
    --                                implementation / type def / codelens
    --   ]d [d  diagnostics, ]w [w    with `jump = { float = true }` above
    -- `gr`/`gi` used to be shadowed here by a global reference/implementation
    -- map, which killed the whole `gr*` family — do not bring that back.
    map("gd", vim.lsp.buf.definition, "Goto Definition")
    map("gD", vim.lsp.buf.declaration, "Goto Declaration")

    map("<leader>df", function() vim.diagnostic.open_float({ scope = "cursor" }) end, "Diagnostics Float")

    -- formatting is owned by conform (<leader>cf / <leader>uf); calling
    -- vim.lsp.buf.format here would silently bypass it
    map("<leader>uh", function()
      local on = not vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
      vim.lsp.inlay_hint.enable(on, { bufnr = buf })
      vim.notify("Inlay hints " .. (on and "on" or "off"), vim.log.levels.INFO)
    end, "Toggle Inlay Hints")

    -- `vim.lsp.buf.restart()` does not exist anymore; `:lsp restart` is the
    -- built-in replacement (nvim-lspconfig's :LspRestart defers to it too)
    map("<leader>lr", "<cmd>lsp restart<cr>", "Restart LSP")
  end,
})
