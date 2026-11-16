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
    for name, kind in vim.fs.dir("lua/cfg/plugins") do
      if kind == "file" and name:sub(-4) == ".lua" then require("cfg.plugins." .. name:sub(1, -5)) end
    end
    for _, name in ipairs({ "cfg.lsp", "cfg.lsp.ui", "cfg.standalone.theme", "cfg.format.indent", "cfg.format.cpp-indent", "cfg.dependencies", "cfg.health" }) do
      require(name)
    end
  end)
  for _, entry in ipairs(saved) do entry[1][entry[2]] = entry[3] end
  assert(ok, err)
  assert(vim.fn.exists(":SetIndent") == 0)
  assert(not package.loaded.conform, "Importing specs loaded a runtime plugin")

  -- Installation queries must reflect newly available tools, without enabling LSP.
  package.loaded["cfg.lsp.servers"] = {
    first = { cmd = { "test-server-first" } },
    second = { cmd = { "test-server-second" } },
  }
  local deps, lsp = require("cfg.dependencies"), require("cfg.lsp")
  local installed, configured, enabled, queried = { ["test-server-first"] = true }, {}, {}, {}
  local resolve, config, enable = deps.resolve, vim.lsp.config, vim.lsp.enable
  deps.resolve = function(command)
    queried[command] = true
    return installed[command] and ("/tools/" .. command) or nil
  end
  vim.lsp.config = function(name) configured[#configured + 1] = name end
  vim.lsp.enable = function(name) enabled[#enabled + 1] = name end
  ok, err = pcall(function()
    assert(vim.deep_equal(lsp.missing(), { "second" }))
    assert(#configured == 0 and #enabled == 0, "A query initialized LSP")
    lsp.setup()
    assert(#configured == 2 and vim.deep_equal(enabled, { "first" }))
    local specs = require("cfg.plugins.mason")
    local installer, integration = specs[4], specs[3]
    assert(vim.list_contains(installer.opts().ensure_installed, "second"))
    assert(vim.deep_equal(integration.opts().automatic_enable, { "second" }))
    assert(queried["tree-sitter"] and not queried["tree-sitter-cli"], "Package name was used as executable")
    installed["test-server-second"] = true
    assert(#lsp.missing() == 0)
    assert(not vim.list_contains(installer.opts().ensure_installed, "second"), "Installer reused a startup snapshot")
    assert(#integration.opts().automatic_enable == 0)
    assert(#configured == 2 and #enabled == 1, "Installer options initialized LSP")
  end)
  deps.resolve, vim.lsp.config, vim.lsp.enable = resolve, config, enable
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
