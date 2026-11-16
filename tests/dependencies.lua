-- Run after init.lua with isolated XDG_STATE_HOME/XDG_CACHE_HOME.
local function check()
  local deps = require("cfg.dependencies")
  local health = require("cfg.health")
  local function by_id(results)
    local indexed = {}
    for _, result in ipairs(results) do indexed[result.tool.id] = result end
    return indexed
  end
  -- A machine without rg can still browse via find, but cannot grep.
  -- Wayland clipboard needs both halves; X11 is a complete alternative.
  local paths = { find = "/bin/find", ["wl-copy"] = "/bin/wl-copy" }
  local function resolve(command) return paths[command] end
  local results = by_id(deps.inspect(resolve))
  assert(results.files.available and not results.search.available)
  assert(not results.clipboard.available)
  paths.xclip = "/bin/xclip"
  assert(by_id(deps.inspect(resolve)).clipboard.available)
  paths.fd = "/bin/fd"
  assert(by_id(deps.inspect(resolve)).files.paths[1] == "/bin/fd")

  local messages, notify = {}, vim.notify
  vim.notify = function(message) messages[#messages + 1] = message end
  local ok, err = pcall(health.notify_missing, deps.inspect(resolve), false)
  vim.notify = notify
  assert(ok, err)
  assert(#messages == 1 and messages[1]:find("Live grep", 1, true))
  assert(messages[1]:find(":checkhealth cfg", 1, true))
  assert(messages[1]:find("Kitty graphics", 1, true))
  assert(not messages[1]:find("PDF", 1, true), "Optional extensions should not nag at startup")
  assert(not messages[1]:find("File picker", 1, true), "Working fallback was reported as missing")

  -- Version checks must reject an installed but outdated CLI.
  local cli = vim.fn.tempname()
  vim.fn.writefile({ "#!/bin/sh", "printf 'tree-sitter 0.25.0\\n'" }, cli)
  vim.fn.setfperm(cli, "rwx------")
  local old = by_id(deps.inspect(function(command) return command == "tree-sitter" and cli or nil end, true))
  vim.fn.delete(cli)
  assert(not old["tree-sitter"].available and old["tree-sitter"].detail:find("0.26.1", 1, true))

  local languages = health.languages()
  local has_verible = false
  for _, result in ipairs(languages) do
    if result.feature == "Formatter verible" then
      has_verible = true
      assert(result.command == "verible-verilog-format", "Formatter name did not resolve to the real executable")
      assert(not (result.detail or ""):find("Unknown formatter", 1, true))
    end
  end
  assert(has_verible)
  print("Dependency checks passed")
end
local ok, err = xpcall(check, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end
