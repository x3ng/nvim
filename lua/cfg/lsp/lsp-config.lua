-- diagnostic config
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
  float = { border = "rounded" },
})

-- lsp keymap
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)

    vim.keymap.set("n", "<leader>lr", function()
      vim.lsp.buf.restart()
      vim.notify("LSP Restarted", vim.log.levels.INFO)
    end, vim.tbl_extend("force", opts, { desc = "Restart LSP" }))
  end,
})

-- auto start lsp
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "c", "cpp", "lua" },
  callback = function(args)
    local ft = args.match
    local server_map = {
      python = 'pyright',
      c = 'clangd',
      cpp = 'clangd',
      lua = 'lua_ls',
    }
    local server_name = server_map[ft]
    if server_name then
      vim.lsp.enable(server_name)
    end
  end,
})
