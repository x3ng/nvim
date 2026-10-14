return {
  "NMAC427/guess-indent.nvim",
  -- Register the detector before BufReadPost; keep base plugin-free.
  event = { "BufReadPre", "BufNewFile" },
  -- Also needed when Conform formats an already-loaded/unnamed buffer.
  lazy = false,
  opts = {
    auto_cmd = false,
    override_editorconfig = false,
  },
  config = function(_, opts)
    local detector = require("guess-indent")
    detector.setup(opts)
    local function detect(buf)
      if not vim.b[buf].manual_indent then detector.set_from_buffer(buf, true, true) end
    end
    local group = vim.api.nvim_create_augroup("UserGuessIndent", { clear = true })
    vim.api.nvim_create_autocmd("BufReadPost", {
      group = group,
      callback = function(args) detect(args.buf) end,
    })
    vim.api.nvim_create_autocmd("BufNewFile", {
      group = group,
      callback = function(args)
        vim.api.nvim_create_autocmd("BufWritePost", {
          group = group,
          buffer = args.buf,
          once = true,
          callback = function(ev) detect(ev.buf) end,
        })
      end,
    })
  end,
}
