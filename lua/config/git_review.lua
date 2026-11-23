local M = {}

local function git_root(dir)
  local result = vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if result.code == 0 then return (result.stdout:gsub("\n$", "")) end
end

local function review_root()
  local file = vim.api.nvim_buf_get_name(0)
  local dir = vim.bo.buftype == "" and file ~= "" and vim.fs.dirname(file)
  local cwd = vim.fn.getcwd()
  local root = (dir and dir ~= cwd and git_root(dir)) or git_root(cwd)
  if not root then vim.notify("Git review requires a file or directory in a Git working tree", vim.log.levels.INFO) end
  return root
end

function M.working_tree()
  local root = review_root()
  if root then Snacks.picker.git_diff({ cwd = root, show_empty = true }) end
end

function M.open(scope)
  local root = review_root()
  if not root then return end
  local function git(args)
    return vim.system(vim.list_extend({ "git" }, args), { cwd = root }):wait()
  end
  local function resolve(ref)
    local result = git({ "rev-parse", "--verify", ref .. "^{commit}" })
    if result.code == 0 then return vim.trim(result.stdout) end
  end

  local head = resolve("HEAD")
  if not head then return vim.notify("No HEAD commit to review", vim.log.levels.WARN) end
  local args, title
  if scope == "commit" then
    args = { "diff-tree", "--root", "--diff-merges=first-parent", "--no-commit-id", "-r", head }
    title = "Last commit " .. head:sub(1, 8)
  else
    local base, name
    for _, ref in ipairs({ "refs/heads/master", "refs/heads/main", "refs/remotes/origin/master", "refs/remotes/origin/main" }) do
      base = resolve(ref)
      if base then
        name = ref:gsub("^refs/heads/", ""):gsub("^refs/remotes/", "")
        break
      end
    end
    if not base then return vim.notify("No master or main reference found", vim.log.levels.WARN) end
    local dots = scope == "branch" and "..." or ".."
    args = { "diff", base .. dots .. head }
    title = name .. dots .. "HEAD"
  end

  -- Keep both sides of renames individually reviewable with a single literal pathspec.
  vim.list_extend(args, { "--no-renames", "--no-ext-diff", "--no-textconv", "--color=never" })
  local files = git(vim.list_extend(vim.deepcopy(args), { "--name-only", "-z", "--" }))
  if files.code ~= 0 then return vim.notify(vim.trim(files.stderr), vim.log.levels.ERROR) end
  if files.stdout == "" then return vim.notify("No changed files in " .. title) end
  local items = {}
  for _, path in ipairs(vim.split(files.stdout, "\0", { plain = true, trimempty = true })) do
    items[#items + 1] = { text = vim.fn.strtrans(path), file = path }
  end
  Snacks.picker.pick({
    title = title,
    cwd = root,
    items = items,
    format = "text",
    confirm = "focus_preview",
    preview = function(ctx)
      local cmd = vim.list_extend({ "git", "--literal-pathspecs" }, args)
      vim.list_extend(cmd, { "--patch", "--", ctx.item.file })
      Snacks.picker.preview.cmd(cmd, ctx, { ft = "diff" })
    end,
  })
end

return M
