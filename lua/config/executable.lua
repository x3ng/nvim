-- Mason may not have appended its bin directory to PATH yet when LSP starts.
return function(command)
  return vim.fn.executable(command) == 1
    or vim.fn.executable(vim.fn.stdpath("data") .. "/mason/bin/" .. command) == 1
end
