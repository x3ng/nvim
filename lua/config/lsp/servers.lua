return {
  ty = {
    cmd = { "ty", "server" },
    filetypes = { "python" },
    root_markers = { "ty.toml", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
  },

  lua_ls = {
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
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=bundled",
      -- clangd logs every TU/stdlib lookup to stderr by default; that ended up
      -- as ~750k lines inside ~/.local/state/nvim/lsp.log
      "--log=error",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", ".git" },
  },

  marksman = {
    cmd = { "marksman" },
    filetypes = { "markdown" },
    root_markers = { ".marksman.toml", ".git" },
  },

  verible = {
    cmd = { "verible-verilog-ls" },
    filetypes = { "verilog", "systemverilog" },
    root_markers = {
      "verible.filelist",
      ".rules.verible_lint",
      ".git",
    },
  },

  rust_analyzer = {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  },

  -- gopls drives workspace loading through the `go` command, so a Go
  -- toolchain should be on PATH (gofmt ships with it too)
  gopls = {
    cmd = { "gopls", "serve" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    settings = {
      gopls = {
        staticcheck = true,
        gofumpt = false, -- conform owns gofmt/goimports (<leader>cf)
        analyses = {
          unusedparams = true,
          nilness = true,
          shadow = true,
          unusedwrite = true,
          useany = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  },

  -- nvim-lspconfig's cmd prefers the project's node_modules/.bin server and its
  -- root_dir excludes Deno projects; only the executable probe is declared here.
  ts_ls = {
    executable = "typescript-language-server",
  },

  nil_ls = {
    cmd = { "nil" },
    filetypes = { "nix" },
    root_markers = { "flake.nix", ".git" },
    settings = {
      ["nil"] = {
        nix = {
          flake = {
            -- Do not fetch missing inputs or prompt when opening Nix files.
            autoArchive = false,
          },
        },
      },
    },
  },

  jsonls = {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { ".git" },
    init_options = { provideFormatter = true },
  },

  html = {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html" },
    root_markers = { "package.json", ".git" },
    init_options = {
      provideFormatter = true,
      embeddedLanguages = { css = true, javascript = true },
      configurationSection = { "html", "css", "javascript" },
    },
  },

  cssls = {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    root_markers = { "package.json", ".git" },
    init_options = { provideFormatter = true },
  },

  yamlls = {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
    root_markers = { ".git" },
    settings = { redhat = { telemetry = { enabled = false } } },
  },

  taplo = {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
    root_markers = { ".taplo.toml", "taplo.toml", ".git" },
  },

  bashls = {
    cmd = { "bash-language-server", "start" },
    filetypes = { "bash", "sh" },
    root_markers = { ".git" },
  },
}
