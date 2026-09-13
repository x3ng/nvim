-- Theme selection, persistence and transparency.
--
--   <leader>ut      toggle transparent background (persisted in stdpath("state"))
--   <leader>uC      browse colorschemes with live preview — needs a picker, so it
--                   is declared in cfg/snacks.lua instead of here
--   `default` below factory fallback used when nothing has been persisted yet
--
-- Both features live here (not in a plugin) so this layer stays dependency-free.
local default = "vscode"

local fn, api = vim.fn, vim.api

local statefile = fn.stdpath("state") .. "/user-theme"
local transparentfile = fn.stdpath("state") .. "/user-transparent"

local function read_state(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local value = f:read("l")
  f:close()
  return value and value ~= "" and value or nil
end

local function write_state(path, value)
  local f = io.open(path, "w")
  if f then
    f:write(value)
    f:close()
  end
end

local persisted = read_state(statefile)

vim.schedule(function()
  -- pcall: a stale persisted name (uninstalled theme) falls back cleanly
  if not (persisted and pcall(vim.cmd.colorscheme, persisted)) then
    pcall(vim.cmd.colorscheme, default)
  end
end)

-- ── Transparency ─────────────────────────────────────────────────────────────
-- Same group set a dedicated plugin used to clear, without the dependency:
-- only groups that actually carry a background are touched.
local transparent_groups = {
  "Normal", "NormalNC", "Comment", "Constant", "Special", "Identifier",
  "Statement", "PreProc", "Type", "Underlined", "Todo", "String", "Function",
  "Conditional", "Repeat", "Operator", "Structure", "LineNr", "NonText",
  "SignColumn", "CursorLine", "CursorLineNr", "StatusLine", "StatusLineNC",
  "EndOfBuffer",
}

local function apply_transparent()
  for _, name in ipairs(transparent_groups) do
    local ok, attrs = pcall(api.nvim_get_hl, 0, { name = name })
    if ok and attrs and attrs.bg then
      attrs.bg = nil
      attrs.ctermbg = nil
      ---@diagnostic disable-next-line: param-type-mismatch
      api.nvim_set_hl(0, name, attrs)
    end
  end
end

if vim.g.transparent_enabled == nil then
  -- enabled unless a previous toggle said otherwise
  vim.g.transparent_enabled = read_state(transparentfile) ~= "0"
end

---@param on boolean
local function set_transparent(on)
  vim.g.transparent_enabled = on
  write_state(transparentfile, on and "1" or "0")
  if on then
    apply_transparent()
  elseif vim.g.colors_name then
    -- reloading the colorscheme restores the original backgrounds
    pcall(vim.cmd.colorscheme, vim.g.colors_name)
  end
end

vim.keymap.set("n", "<leader>ut", function()
  set_transparent(not vim.g.transparent_enabled)
  vim.notify("Transparency " .. (vim.g.transparent_enabled and "on" or "off"), vim.log.levels.INFO)
end, { desc = "Toggle Transparency" })

-- ── Persistence ──────────────────────────────────────────────────────────────
-- remember every explicit switch (picker, :colorscheme, theme toggles) and keep
-- transparency applied on top of whatever the theme just set
api.nvim_create_autocmd("ColorScheme", {
  group = api.nvim_create_augroup("UserTheme", { clear = true }),
  callback = function(args)
    write_state(statefile, args.match)
    if vim.g.transparent_enabled then apply_transparent() end
  end,
})
