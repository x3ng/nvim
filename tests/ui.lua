-- Headless runtime check with isolated cache/state; starts a local shell only.
local function check()
  local function invoke(lhs)
    local map = vim.fn.maparg(lhs, "n", false, true)
    assert(type(map.callback) == "function", "Missing callback: " .. lhs)
    map.callback()
  end

  vim.o.shell = assert(vim.fn.exepath("sh"), "A POSIX shell is needed for this test")
  invoke("<C-/>")
  local term = assert(Snacks.terminal.get(nil, { create = false }))
  local buf, job = term.buf, vim.b[term.buf].terminal_job_id
  assert(job and vim.fn.jobwait({ job }, 0)[1] == -1, "Shell did not start")
  assert(vim.api.nvim_win_get_config(term.win).relative ~= "", "Expected float")

  local function same_shell()
    assert(term.buf == buf and vim.b[buf].terminal_job_id == job, "Layout change replaced shell")
    assert(#Snacks.terminal.list() == 1, "Layout change created extra terminals")
    assert(vim.fn.jobwait({ job }, 0)[1] == -1, "Shell exited during layout change")
  end
  invoke("<leader>th")
  same_shell()
  assert(term.opts.position == "bottom" and vim.api.nvim_win_get_config(term.win).relative == "")
  assert(vim.api.nvim_win_get_height(term.win) < vim.o.lines * 0.5, "Bottom terminal is too tall")
  invoke("<leader>th")
  assert(not term:win_valid(), "Repeated layout did not hide terminal")
  same_shell()
  invoke("<leader>tv")
  same_shell()
  assert(term.opts.position == "right" and vim.api.nvim_win_get_config(term.win).relative == "")
  assert(vim.api.nvim_win_get_width(term.win) < vim.o.columns * 0.6, "Right terminal is too wide")
  invoke("<C-/>")
  same_shell()
  assert(vim.api.nvim_win_get_config(term.win).relative ~= "", "Did not return to float")
  term:hide()
  invoke("<C-/>")
  same_shell()
  -- Sending a command after moving/hiding verifies the shell is usable.
  vim.api.nvim_chan_send(job, "printf 'ui-shell-%s\\n' alive\n")
  assert(vim.wait(2000, function()
    return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"):find("ui-shell-alive", 1, true) ~= nil
  end), "Reopened shell did not respond")
  vim.api.nvim_chan_send(job, "exit\n")
  assert(vim.wait(2000, function() return not vim.api.nvim_buf_is_valid(buf) end), "Successful exit did not close terminal")

  -- Noice intentionally avoids UI setup in headless mode; configure its real
  -- router/source explicitly, without attaching the external message UI.
  local config = require("noice.config")
  config.setup(require("cfg.plugins.noice").opts)
  require("noice.commands").setup()
  local router = require("noice.message.router")
  router.setup()
  require("noice.source.notify").enable()
  assert(vim.notify == require("noice.source.notify").notify, "Noice does not own vim.notify")
  assert(require("noice.view").get_view("notify")._opts.backend == "snacks")
  assert(Snacks.config.notifier.level == vim.log.levels.INFO)

  vim.notify("ui-review-notification", vim.log.levels.WARN)
  local manager = require("noice.message.manager")
  local Message = require("noice.message")
  manager.add(Message("msg_show", "echomsg", "ui-review-editor-message"))
  local warning = Message("msg_show", "wmsg", "ui-review-editor-warning")
  warning.level = "warn"
  manager.add(warning)
  router.update()
  local items = require("noice.integrations.snacks").find()
  for _, content in ipairs({ "ui-review-notification", "ui-review-editor-message", "ui-review-editor-warning" }) do
    local count = 0
    for _, item in ipairs(items) do
      if item.message:content():find(content, 1, true) then count = count + 1 end
    end
    assert(count == 1, "History missing or duplicating: " .. content)
  end
  local shown = Snacks.notifier.get_history()
  for _, content in ipairs({ "ui-review-notification", "ui-review-editor-warning" }) do
    local found = false
    for _, item in ipairs(shown) do if item.msg:find(content, 1, true) then found = true end end
    assert(found, "Notification did not reach Snacks: " .. content)
  end
  assert(vim.fn.maparg("<leader>nh", "n"):find("Noice snacks", 1, true))
  invoke("<leader>nd")
  assert(#require("noice.integrations.snacks").find() == #items, "Dismiss erased history")
  assert(vim.fn.maparg("<leader>nm", "n") == "" and vim.fn.maparg("<leader>nc", "n") == "")
  require("noice.source.notify").disable()
  print("Terminal lifecycle and unified message checks passed")
end

local ok, err = xpcall(check, debug.traceback)
-- Also clean up the test shell when an assertion fails.
for _, term in ipairs(Snacks.terminal.list()) do
  local job = vim.b[term.buf].terminal_job_id
  if job then pcall(vim.fn.jobstop, job) end
  term:close()
end
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end
