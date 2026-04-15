-- C/C++: clangd
vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--header-insertion=iwyu',
    '--completion-style=bundled',
  },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
  root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', '.git' },
})
