-- Run after init.lua with isolated XDG_STATE_HOME/XDG_CACHE_HOME.
local function check()
  local function mapping(key, mode)
    return vim.fn.maparg("<leader>" .. key, mode or "n", false, true)
  end
  local function present(key, mode)
    assert(next(mapping(key, mode)), "Missing leader mapping: " .. key)
  end
  -- These actions are conditional in regular editing; check their real hooks.
  require("lazy").load({ plugins = { "gitsigns.nvim", "which-key.nvim" } })
  require("cfg.gitsigns").opts.on_attach(vim.api.nvim_get_current_buf())
  for _, group in ipairs({ "UserLspConfig", "UserMarkdownPreview" }) do
    local hooks = vim.api.nvim_get_autocmds({ group = group })
    assert(#hooks == 1)
    hooks[1].callback({ buf = vim.api.nvim_get_current_buf() })
  end
  for _, key in ipairs({
    "ff", "fe", "fE", "fn", "fr", "fp", "bb", "bd", "bs", "bS",
    "sg", "ss", "sS", "sd", "sD", "sc", "sh", "sk", "sm", "sj", "sl", "sq", "s/", "s:",
    "sr", "sw", "sb", "st", "cf", "cd", "cr", "cp", "hs", "hr", "hp", "hb", "hd",
    "gg", "gG", "gb", "gl", "gL", "gs", "gS", "gd", "uw", "ul", "uc", "uC", "uh", "us",
    "nm", "nc", "nh", "nd", "th", "tv", "qq", "qs", "qS", "ql", "qd", "w",
  }) do present(key) end
  present("sv", "x")
  present("cf", "x")
  for _, key in ipairs({
    "fb", "ce", "fg", "fs", "fS", "fd", "fD", "fc", "fh", "fk", "fm", "fj", "fl", "fq", "f/", "f:",
    "df", "lr", "mp", ".", "S",
  }) do assert(not next(mapping(key)), "Old mapping still present: " .. key) end

  -- Verify callback dispatch without launching external processes or picker UI.
  local original = Snacks
  local called = {}
  local ok, err = pcall(function()
    _G.Snacks = { picker = {} }
    for _, source in ipairs({
      "buffers", "grep", "commands", "help", "diagnostics", "diagnostics_buffer", "lsp_symbols",
      "lsp_workspace_symbols", "keymaps", "marks", "jumps", "loclist", "qflist", "search_history", "command_history",
    }) do
      Snacks.picker[source] = function() called[#called + 1] = source end
    end
    for _, key in ipairs({ "bb", "sg", "sc", "sh", "sd", "sD", "ss", "sS", "sk", "sm", "sj", "sl", "sq", "s/", "s:" }) do
      mapping(key).callback()
    end
    assert(vim.deep_equal(called, {
      "buffers", "grep", "commands", "help", "diagnostics", "diagnostics_buffer", "lsp_symbols",
      "lsp_workspace_symbols", "keymaps", "marks", "jumps", "loclist", "qflist", "search_history", "command_history",
    }))
  end)
  _G.Snacks = original
  assert(ok, err)

  -- A complete action must not also be a prefix for another action.
  for _, mode in ipairs({ "n", "x", "o" }) do
    local keys = {}
    for _, maps in ipairs({ vim.api.nvim_get_keymap(mode), vim.api.nvim_buf_get_keymap(0, mode) }) do
      for _, map in ipairs(maps) do
        if map.lhs:sub(1, 1) == " " then keys[map.lhs] = true end
      end
    end
    for first in pairs(keys) do
      for second in pairs(keys) do
        assert(first == second or second:sub(1, #first) ~= first, "Action is also a prefix: " .. first .. " / " .. second)
      end
    end
  end
  print("Leader mapping checks passed")
end
local ok, err = xpcall(check, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end
