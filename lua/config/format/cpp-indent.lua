local M = {}
local filetypes = { c = true, cpp = true, objc = true, objcpp = true, cuda = true }
local running, queued = {}, {}

function M.sync(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  local bo = vim.bo[buf]
  if not filetypes[bo.filetype] or bo.buftype ~= "" or vim.b[buf].manual_indent then return end
  if vim.fn.executable("clang-format") ~= 1 then return end

  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then return end
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  local previous = running[buf]
  if previous and previous.name == name and previous.tick == tick then return end
  -- Invalidate any result for an earlier name/content before checking eligibility.
  running[buf] = nil
  local project_style = vim.fs.find({ ".clang-format", "_clang-format" }, {
    path = vim.fs.dirname(name),
    upward = true,
  })[1]
  if not project_style then
    -- Without a project style, preserve EditorConfig and existing indentation.
    -- Only use clangd's fallback for a new/unindented file needing a default.
    local ec = vim.b[buf].editorconfig
    if ec and (ec.indent_style or ec.indent_size or ec.tab_width) then return end
    for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, math.min(1028, vim.api.nvim_buf_line_count(buf)), false)) do
      if line:match("^%s+%S") then return end
    end
  end
  -- Ask clang-format to resolve parent configs, inheritance and language
  -- sections exactly as clangd does. LLVM is clangd's default fallback style.
  local request = { name = name, tick = tick }
  running[buf] = request
  local ok = pcall(
    vim.system,
    {
      "clang-format",
      "--style=file",
      "--fallback-style=LLVM",
      "--assume-filename=" .. name,
      "--dump-config",
    },
    { text = true, timeout = 1000 },
    vim.schedule_wrap(function(result)
      if running[buf] ~= request then return end
      running[buf] = nil
      -- Never overwrite a newer edit, rename, filetype or manual indent choice.
      if
        not vim.api.nvim_buf_is_valid(buf)
        or vim.api.nvim_buf_get_name(buf) ~= name
        or vim.api.nvim_buf_get_changedtick(buf) ~= tick
        or vim.b[buf].manual_indent
        or not filetypes[vim.bo[buf].filetype]
        or vim.bo[buf].buftype ~= ""
        or result.code ~= 0
      then
        return
      end
      local config = "\n" .. (result.stdout or "")
      local width = tonumber(config:match("\nIndentWidth:%s*(%d+)"))
      local tabs = tonumber(config:match("\nTabWidth:%s*(%d+)"))
      local use_tab = config:match("\nUseTab:%s*(%S+)")
      if not width or width < 1 or not tabs or tabs < 1 or not use_tab then return end
      bo.shiftwidth = width
      bo.tabstop = tabs
      bo.softtabstop = -1
      bo.expandtab = use_tab == "Never"
    end)
  )
  -- Invalid configs/missing tools leave EditorConfig and file detection intact.
  if not ok then running[buf] = nil end
end

function M.setup()
  vim.api.nvim_create_autocmd({ "FileType", "BufReadPost", "BufFilePost" }, {
    group = vim.api.nvim_create_augroup("UserCppIndent", { clear = true }),
    desc = "Match C/C++ editing indentation to clangd formatting",
    callback = function(args)
      local buf = args.buf
      if not filetypes[vim.bo[buf].filetype] or queued[buf] then return end
      -- Coalesce opening events, then run after ftplugins and indent detection.
      queued[buf] = true
      vim.schedule(function()
        queued[buf] = nil
        M.sync(buf)
      end)
    end,
  })
end

return M
