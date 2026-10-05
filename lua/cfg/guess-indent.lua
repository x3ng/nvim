return {
  "NMAC427/guess-indent.nvim",
  -- Register the detector before BufReadPost; keep base plugin-free.
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    auto_cmd = true,
    override_editorconfig = false,
  },
}
