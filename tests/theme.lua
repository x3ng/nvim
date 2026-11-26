-- Run with isolated XDG_STATE_HOME/XDG_CACHE_HOME; see README.md.
local function check()
  local api = vim.api
  local state = vim.fn.stdpath("state")
  local function saved(name) return vim.fn.readfile(state .. "/" .. name)[1] end
  local function hl(name) return api.nvim_get_hl(0, { name = name, link = false }) end
  assert(vim.g.colors_name == "vscode", "Startup fallback was not applied synchronously")
  assert(vim.fn.maparg("<leader>ut", "n") == "", "Transparency toggle still exists")
  -- Legacy state must not override native theme backgrounds.
  vim.fn.writefile({ "1" }, state .. "/user-transparent")
  for _, theme in ipairs({ "vscode", "gruvbox", "tokyonight-night", "catppuccin-mocha" }) do
    vim.cmd.colorscheme(theme)
    assert(hl("Normal").bg, theme .. ": missing opaque background")
    assert(saved("user-theme") == theme)
  end

  vim.cmd.colorscheme("vscode")
  local picker = Snacks.picker.colorschemes({ pattern = "gruvbox" })
  assert(vim.wait(3000, function() return vim.g.colors_name == "gruvbox" end), "Live preview did not apply")
  assert(saved("user-theme") == "vscode", "Browsing saved a temporary theme")
  picker:close()
  vim.wait(100, function() return false end)
  assert(vim.g.colors_name == "vscode" and saved("user-theme") == "vscode", "Cancel changed theme")
  local background = vim.o.background
  picker = Snacks.picker.colorschemes({ pattern = "tokyonight-day" })
  assert(vim.wait(3000, function() return vim.g.colors_name == "tokyonight-day" end))
  assert(saved("user-theme") == "vscode")
  picker:close()
  vim.wait(100, function() return false end)
  assert(vim.g.colors_name == "vscode" and vim.o.background == background, "Cancel did not restore background")
  picker = Snacks.picker.colorschemes({ pattern = "gruvbox" })
  assert(vim.wait(3000, function() return picker:current() and picker:current().text == "gruvbox" end))
  picker:action("confirm")
  assert(vim.wait(3000, function() return vim.g.colors_name == "gruvbox" end), "Confirmation did not apply theme")
  assert(saved("user-theme") == "gruvbox")
  vim.wait(100, function() return false end)
  assert(vim.g.colors_name == "gruvbox", "A delayed preview overrode confirmation")
  -- Reload persisted state through the same startup entry point.
  vim.g.colors_name = nil
  require("config.theme").load()
  assert(vim.g.colors_name == "gruvbox" and hl("Normal").bg)
  vim.o.background = "light"
  vim.cmd.colorscheme("gruvbox")
  assert(vim.fn.readfile(state .. "/user-theme")[2] == "light")
  require("config.theme").preview("gruvbox", "dark")
  require("config.theme").load()
  assert(vim.g.colors_name == "gruvbox" and vim.o.background == "light", "Background was not restored")
  vim.fn.writefile({ "uninstalled-theme" }, state .. "/user-theme")
  require("config.theme").load()
  assert(vim.g.colors_name == "vscode" and saved("user-theme") == "vscode")
  print("Theme checks passed")
end

local ok, err = xpcall(check, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end
