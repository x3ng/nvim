-- Haskell: haskell-language-server
vim.lsp.config('hls', {
  cmd = { 'haskell-language-server-wrapper', '--lsp' },
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
  root_markers = { 'stack.yaml', 'cabal.project', 'hie.yaml', '*.cabal', '.git' },
  settings = {
    haskell = {
      formattingProvider = 'fourmolu',
      plugin = {
        tactics = {
          config = { auto_gas = 3 },
        },
      },
    },
  },
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'haskell', 'lhaskell', 'cabal' },
  callback = function() vim.lsp.enable('hls') end,
})
