-- Editor indentation policy: manual overrides and re-detection after formatting.
-- Formatter names live in config.format; this module only changes buffer options.
local M = {}

function M.setup()
  vim.api.nvim_create_user_command("SetIndent", function(opts)
    local args = opts.fargs
    local style = #args == 1 and "space" or args[1]
    local size = tonumber(args[#args])
    if #args > 2 or (style ~= "space" and style ~= "tab") or not size or size < 1 or size > 16 or size % 1 ~= 0 then
      vim.notify("Usage: SetIndent [space|tab] <width 1..16>", vim.log.levels.ERROR)
      return
    end
    vim.bo.shiftwidth = size
    vim.bo.tabstop = size
    vim.bo.softtabstop = -1 -- follow shiftwidth
    vim.bo.expandtab = style == "space"
    vim.b.manual_indent = true -- preserve this choice against automatic indent detection
  end, {
    desc = "Set current buffer indent style and width",
    nargs = "+",
    complete = function() return { "2", "4", "8", "space", "tab" } end
  })
end

-- Formatter output is the authoritative indentation after formatting. This
-- also handles formatters whose defaults do not consult EditorConfig/LSP opts.
function M.after_format(buf)
  return function(err, did_edit)
    if err or not did_edit or not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].manual_indent then return end
    vim.api.nvim_buf_call(buf, function()
      require("guess-indent").set_from_buffer(buf, false, true)
      vim.bo[buf].softtabstop = -1
    end)
  end
end

return M
