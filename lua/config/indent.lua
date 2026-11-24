local M = {}

function M.setup()
  vim.api.nvim_create_user_command("SetIndent", function(opts)
    local args = opts.fargs
    local style = #args == 1 and "space" or args[1]
    local width = tonumber(args[#args])
    if #args > 2 or (style ~= "space" and style ~= "tab") or not width or width < 1 or width > 16 or width % 1 ~= 0 then
      vim.notify("Usage: SetIndent [space|tab] <width 1..16>", vim.log.levels.ERROR)
      return
    end
    vim.bo.vartabstop = ""
    vim.bo.varsofttabstop = ""
    vim.bo.shiftwidth = width
    vim.bo.tabstop = width
    vim.bo.softtabstop = -1
    vim.bo.expandtab = style == "space"
  end, {
    desc = "Set indentation for this buffer",
    nargs = "+",
    complete = function() return { "2", "4", "8", "space", "tab" } end,
  })
end

return M
