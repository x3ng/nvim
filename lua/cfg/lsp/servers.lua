return {
  pyright = {
    mason = true,
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", ".git" },
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  },

  lua_ls = {
    mason = true,
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luacheckrc", ".git" },
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },

  clangd = {
    mason = true,
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=bundled",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", ".git" },
  },

  hls = {
    -- Mason installs HLS via ghcup. If ghcup is unavailable, prefer PATH-provided HLS.
    mason = vim.fn.executable("ghcup") == 1,
    cmd = { "haskell-language-server-wrapper", "--lsp" },
    filetypes = { "haskell", "lhaskell", "cabal" },
    root_markers = { "stack.yaml", "cabal.project", "hie.yaml", "*.cabal", ".git" },
    settings = {
      haskell = {
        formattingProvider = "fourmolu",
        plugin = {
          tactics = {
            config = { auto_gas = 3 },
          },
        },
      },
    },
  },

  marksman = {
    mason = true,
    cmd = { "marksman" },
    filetypes = { "markdown" },
    root_markers = { ".marksman.toml", ".git" },
  },

  verible = {
    mason = true,
    cmd = { "verible-verilog-ls" },
    filetypes = { "verilog", "systemverilog" },
    root_markers = {
      "verible.filelist",
      ".rules.verible_lint",
      ".git",
    },
  },

  rust_analyzer = {
    mason = true,
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  },

  vtsls = {
    mason = true,
    cmd = { "vtsls", "--stdio" },
    filetypes = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
    root_markers = {
      "package.json",
      "tsconfig.json",
      "jsconfig.json",
      ".git",
    },
  },
}
