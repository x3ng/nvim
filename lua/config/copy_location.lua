-- Copy the current location (or visual range), with optional code, for agents.
-- Absolute paths keep the reference unambiguous regardless of the agent's cwd.
local M = {}

local function current_line()
  return vim.fn.line("."), vim.fn.line(".")
end

-- Visual mappings run as `:<C-U>` commands, so the `'<` / `'>` marks are set.
local function visual_lines()
  local first, last = vim.fn.line("'<"), vim.fn.line("'>")
  if first == 0 or last == 0 then
    return current_line()
  end
  return math.min(first, last), math.max(first, last)
end

-- Returns the location text, failure message, file path and line range.
local function location(visual)
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return nil, "No file path to copy"
  end

  local first, last
  if visual then
    first, last = visual_lines()
  else
    first, last = current_line()
  end
  local lines = first == last and tostring(first) or first .. "-" .. last
  return path .. ":" .. lines, nil, first, last
end

local function copy(text, summary)
  -- `+` needs a clipboard provider; fall back to the unnamed register.
  pcall(vim.fn.setreg, "+", text)
  pcall(vim.fn.setreg, "*", text)
  vim.fn.setreg('"', text)
  vim.api.nvim_echo({ { "Copied " .. summary } }, false, {})
end

function M.copy_location(visual)
  local text, err = location(visual)
  if not text then
    vim.notify(err, vim.log.levels.WARN)
    return
  end
  copy(text, text)
end

function M.copy_with_code(visual)
  local text, err, first, last = location(visual)
  if not text then
    vim.notify(err, vim.log.levels.WARN)
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  copy(table.concat(lines, "\n") .. "\n" .. text, text .. " with code")
end

local function visual_mapping(func)
  return string.format(
    ":<C-U>lua require('config.copy_location').%s(true)<CR>",
    func
  )
end

function M.setup()
  vim.keymap.set("n", "gy", function() M.copy_location(false) end, { desc = "Copy location" })
  vim.keymap.set("x", "gy", visual_mapping("copy_location"), { silent = true, desc = "Copy location" })
  vim.keymap.set("n", "gY", function() M.copy_with_code(false) end, { desc = "Copy location with code" })
  vim.keymap.set("x", "gY", visual_mapping("copy_with_code"), { silent = true, desc = "Copy location with code" })
end

return M
