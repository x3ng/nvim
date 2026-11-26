-- Theme selection and persistence. Colors are owned entirely by the theme.
--
--   <leader>uC      choose a colorscheme — needs a picker, so it
--                   is declared in plugins/snacks.lua instead of here
--   `default` below factory fallback used when nothing has been persisted yet
--
-- This layer stays dependency-free.
local default = "vscode"

local fn, api = vim.fn, vim.api

local statefile = fn.stdpath("state") .. "/user-theme"
local previewing = false

-- Line 1 is the colorscheme; optional line 2 is 'background' (older files lack it).
local function read_state(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local value, background = f:read("l"), f:read("l")
  f:close()
  if background ~= "light" and background ~= "dark" then background = nil end
  return value and value ~= "" and value or nil, background
end

local function write_state(path, value, background)
  fn.mkdir(fn.stdpath("state"), "p")
  local f = io.open(path, "w")
  if f then
    f:write(value .. "\n" .. background .. "\n")
    f:close()
  end
end

-- ── Persistence ──────────────────────────────────────────────────────────────
-- Remember explicit switches (picker confirmation or :colorscheme).
return {
  setup = function()
    api.nvim_create_autocmd("ColorScheme", {
      group = api.nvim_create_augroup("UserTheme", { clear = true }),
      callback = function(args)
        if not previewing then write_state(statefile, args.match, vim.o.background) end
      end,
    })
  end,
  -- Fire normal ColorScheme events for UI integrations without saving previews.
  preview = function(name, background)
    previewing = true
    local ok, err = pcall(function()
      if background then vim.o.background = background end
      vim.cmd.colorscheme(name)
    end)
    previewing = false
    if not ok then vim.notify(tostring(err), vim.log.levels.WARN, { title = "Theme preview" }) end
  end,
  -- Called after lazy.setup so theme plugins can be loaded by :colorscheme.
  load = function()
    local persisted, background = read_state(statefile)
    if background then vim.o.background = background end
    if not (persisted and pcall(vim.cmd.colorscheme, persisted)) then
      if not pcall(vim.cmd.colorscheme, default) then vim.cmd.colorscheme("default") end
    end
  end,
}
