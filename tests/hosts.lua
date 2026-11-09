-- Run after init.lua in a headless process; see docs/vscode.md.
local function check()
  local vscode = not not vim.g.vscode
  assert(vim.g.mapleader == " " and vim.o.ignorecase and vim.o.smartcase)
  assert(vim.filetype.match({ filename = "module.vh" }) == "verilog")
  local config = require("lazy.core.config")
  assert(#config.spec.notifs == 0, vim.inspect(config.spec.notifs))
  if vscode then
    assert(package.loaded["cfg.vscode"])
    for _, name in ipairs({ "cfg.standalone", "cfg.lsp", "cfg.lsp.lsp-config", "cfg.format.cpp-indent", "cfg.standalone.theme" }) do
      assert(not package.loaded[name], "Standalone module leaked: " .. name)
    end
    assert(vim.fn.exists(":SetIndent") == 0)
    assert(vim.fn.maparg("<C-a>", "i") == "")
    assert(vim.fn.maparg("<C-a>", "c") == "<Home>")
    for name in pairs(config.plugins) do
      assert(name == "lazy.nvim" or name == "nvim-surround" or name == "vim-repeat", "Unexpected active plugin: " .. name)
    end
    for _, name in ipairs({ "snacks.nvim", "noice.nvim", "blink.cmp", "mason.nvim", "nvim-treesitter", "fcitx.nvim" }) do
      assert(config.spec.ignore_installed[name], "Plugin not protected from clean: " .. name)
    end
    local calls, settings = {}, { ["editor.lineNumbers"] = "on", ["editor.renderLineHighlight"] = "line", ["editor.inlayHints.enabled"] = "on" }
    package.loaded.vscode = {
      action = function(command) calls[#calls + 1] = command end,
      get_config = function(name) return settings[name] end,
      update_config = function(name, value) settings[name] = value end,
    }
    local function invoke(lhs, mode)
      local mapping = vim.fn.maparg(lhs, mode or "n", false, true)
      assert(type(mapping.callback) == "function", "Missing callback: " .. lhs)
      mapping.callback()
    end
    invoke("<leader>ff")
    invoke("<leader>cf")
    invoke("<leader>cf", "x")
    invoke("grr")
    assert(vim.deep_equal(calls, {
      "workbench.action.quickOpen", "editor.action.formatDocument",
      "editor.action.formatSelection", "editor.action.goToReferences",
    }))
    invoke("<leader>ul")
    invoke("<leader>uc")
    invoke("<leader>uh")
    assert(settings["editor.inlayHints.enabled"] == "off")
    assert(settings["editor.lineNumbers"] == "relative" and settings["editor.renderLineHighlight"] == "none")
    invoke("<leader>ul")
    invoke("<leader>uc")
    invoke("<leader>uh")
    assert(settings["editor.inlayHints.enabled"] == "on")
    assert(settings["editor.lineNumbers"] == "on" and settings["editor.renderLineHighlight"] == "line")
  else
    assert(package.loaded["cfg.standalone"] and package.loaded["cfg.lsp"])
    assert(not package.loaded["cfg.vscode"])
    assert(config.plugins["snacks.nvim"] and config.plugins["blink.cmp"])
    assert(vim.o.number and vim.o.relativenumber and vim.o.laststatus == 3)
    assert(vim.fn.maparg("<C-a>", "i") == "<Home>")
    assert(vim.fn.maparg("<leader>w", "n") == "<Cmd>w<CR>" or vim.fn.maparg("<leader>w", "n") == "<cmd>w<cr>")
    vim.cmd("SetIndent tab 8")
    assert(vim.bo.shiftwidth == 8 and not vim.bo.expandtab and vim.b.manual_indent)
  end
  require("lazy").load({ plugins = { "nvim-surround" } })
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "word" })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.cmd("normal ysiw)")
  assert(vim.api.nvim_get_current_line() == "(word)", "Surround editing failed")
  print((vscode and "VSCode" or "Standalone") .. " host checks passed")
end
local ok, err = xpcall(check, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end
