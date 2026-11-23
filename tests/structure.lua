-- Run with -u NONE: the import boundary is tested without starting the config.
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local function check()
  -- Initialize Neovim's own lazy LSP module before guarding config imports.
  local lsp_api = vim.lsp
  local saved = {}
  local function forbid(owner, name)
    saved[#saved + 1] = { owner, name, owner[name] }
    owner[name] = function() error("Module import performed an effect: " .. name) end
  end
  forbid(vim.api, "nvim_create_autocmd")
  forbid(vim.api, "nvim_create_user_command")
  forbid(lsp_api, "enable")
  forbid(lsp_api, "config")
  forbid(vim, "notify")
  forbid(vim, "schedule")
  forbid(vim, "system")
  forbid(vim.fn, "system")
  forbid(vim.fn, "exepath")
  forbid(vim.fn, "executable")
  local ok, err = pcall(function()
    for name, kind in vim.fs.dir("lua/plugins") do
      if kind == "file" and name:sub(-4) == ".lua" then require("plugins." .. name:sub(1, -5)) end
    end
    for _, name in ipairs({ "config.format.formatters", "config.lsp.servers" }) do
      assert(not package.loaded[name], "Importing specs loaded " .. name)
    end
    for _, name in ipairs({ "config.lsp", "config.lsp.ui", "config.theme", "config.indent" }) do
      require(name)
    end
  end)
  for _, entry in ipairs(saved) do entry[1][entry[2]] = entry[3] end
  assert(ok, err)
  assert(vim.fn.exists(":SetIndent") == 0)
  assert(not package.loaded.conform, "Importing specs loaded a runtime plugin")
  -- Installation queries must reflect newly available tools, without enabling LSP.
  package.loaded["config.lsp.servers"] = {
    first = { cmd = { "test-server-first" } },
    second = { cmd = { "test-server-second" } },
  }
  local lsp = require("config.lsp")
  local installed, configured, enabled, queried = { ["test-server-first"] = true }, {}, {}, {}
  local executable, config, enable = vim.fn.executable, vim.lsp.config, vim.lsp.enable
  vim.fn.executable = function(command)
    queried[command] = true
    local name = command:match("([^/]+)$")
    return installed[name] and 1 or 0
  end
  vim.lsp.config = function(name) configured[#configured + 1] = name end
  vim.lsp.enable = function(name) enabled[#enabled + 1] = name end
  ok, err = pcall(function()
    assert(vim.deep_equal(lsp.missing(), { "second" }))
    assert(#configured == 0 and #enabled == 0, "A query initialized LSP")
    lsp.setup()
    assert(#configured == 2 and vim.deep_equal(enabled, { "first" }))
    local specs = require("plugins.mason")
    local function spec(name)
      for _, candidate in ipairs(specs) do
        if candidate[1] == name then return candidate end
      end
    end
    local installer = assert(spec("WhoIsSethDaniel/mason-tool-installer.nvim"))
    local integration = assert(spec("mason-org/mason-lspconfig.nvim"))
    assert(vim.list_contains(installer.opts().ensure_installed, "stylua"))
    assert(not vim.list_contains(installer.opts().ensure_installed, "second"), "Installer received an lspconfig name")
    assert(integration.opts().automatic_enable == true)
    assert(queried["tree-sitter"] and not queried["tree-sitter-cli"], "Package name was used as executable")
    installed["test-server-second"] = true
    assert(#lsp.missing() == 0)
    installed["stylua"] = true
    assert(not vim.list_contains(installer.opts().ensure_installed, "stylua"), "Installer ignored PATH tools")
    installed["tree-sitter"] = true
    assert(not vim.list_contains(installer.opts().ensure_installed, "tree-sitter-cli"), "Package name was used as executable")
    assert(integration.opts().automatic_enable == true)
    assert(#configured == 2 and #enabled == 1, "Installer options initialized LSP")
  end)
  vim.fn.executable, vim.lsp.config, vim.lsp.enable = executable, config, enable
  assert(ok, err)
  print("Structure and initialization checks passed")
end

local ok, err = xpcall(check, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end
