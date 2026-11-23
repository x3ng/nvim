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

local function read_state(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local value = f:read("l")
  f:close()
  return value and value ~= "" and value or nil
end

local function write_state(path, value)
  fn.mkdir(fn.stdpath("state"), "p")
  local f = io.open(path, "w")
  if f then
    f:write(value)
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
        if not previewing then write_state(statefile, args.match) end
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
    local persisted = read_state(statefile)
    if not (persisted and pcall(vim.cmd.colorscheme, persisted)) then
      if not pcall(vim.cmd.colorscheme, default) then vim.cmd.colorscheme("default") end
    end
  end,
}
