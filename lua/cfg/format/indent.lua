local M = {}

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
