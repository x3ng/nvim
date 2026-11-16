local M = {}

function M.unmanaged_formatters()
  local tools = require("cfg.format.tools")
  local missing = {}
  for _, names in pairs(require("cfg.format.formatters")) do
    for _, name in ipairs(names) do
      if not vim.list_contains(tools.packages, name) and not tools.external[name] then missing[name] = true end
    end
  end
  local result = vim.tbl_keys(missing)
  table.sort(result)
  return result
end

-- Explicit health checks may load Conform; ordinary startup only probes tools.
function M.languages()
  local deps = require("cfg.dependencies")
  local results = {}
  for name, config in pairs(require("cfg.lsp.servers")) do
    local command = config.cmd[1]
    local path = deps.resolve(command, true)
    results[#results + 1] = { feature = "LSP " .. name, command = command, path = path }
  end
  local conform = require("conform")
  local names = {}
  for _, formatters in pairs(require("cfg.format.formatters")) do
    for _, name in ipairs(formatters) do names[name] = true end
  end
  for name in pairs(names) do
    local info = conform.get_formatter_info(name)
    results[#results + 1] = {
      feature = "Formatter " .. name, command = info.command,
      path = info.available and deps.resolve(info.command) or nil, detail = info.available_msg, error = info.error,
    }
  end
  table.sort(results, function(a, b) return a.feature < b.feature end)
  return results
end

function M.notify_missing(results, terminal)
  local deps = require("cfg.dependencies")
  local missing = {}
  for _, result in ipairs(results) do
    if result.tool.startup and not result.available then
      missing[#missing + 1] = deps.requirement(result.tool) .. " → " .. result.tool.feature
    end
  end
  if terminal == false then missing[#missing + 1] = "Kitty graphics protocol → image display unavailable in this terminal" end
  local unmanaged = M.unmanaged_formatters()
  if #unmanaged > 0 then missing[#missing + 1] = "Formatters without an installation source: " .. table.concat(unmanaged, ", ") end
  if #missing > 0 then
    vim.notify("Missing dependencies:\n" .. table.concat(missing, "\n") .. "\nRun :checkhealth cfg for paths and setup instructions.",
      vim.log.levels.WARN, { title = "Neovim dependencies", timeout = 10000 })
  end
end

function M.setup()
  if vim.g.vscode then return end
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("UserDependencies", { clear = true }),
    once = true,
    callback = function()
      -- No subprocesses, installers or terminal queries in the headless path.
      if #vim.api.nvim_list_uis() == 0 then return end
      vim.schedule(function()
        local results = require("cfg.dependencies").inspect()
        if not Snacks.config.image.enabled then
          M.notify_missing(results)
          return
        end
        Snacks.image.terminal.detect(function()
          M.notify_missing(results, Snacks.image.terminal.env().supported == true)
        end)
      end)
    end,
  })
end

function M.check()
  local health = vim.health
  if vim.g.vscode then
    health.start("External dependencies")
    health.info("VSCode owns UI and language services; standalone dependency checks do not apply.")
    return
  end
  local deps = require("cfg.dependencies")
  health.start("Configured tools (PATH order; no automatic installation)")
  for _, result in ipairs(deps.inspect(nil, true)) do
    local tool = result.tool
    local label = tool.feature .. " [" .. deps.requirement(tool) .. "]"
    if result.available then
      health.ok(label .. ": " .. table.concat(result.paths, ", ") .. (result.detail and " (" .. result.detail .. ")" or ""))
    else
      local report = tool.optional and health.info or health.warn
      report((tool.optional and "Optional: " or "Missing: ") .. label
        .. (result.detail and "\n" .. result.detail or "") .. "\n" .. deps.hint(tool))
    end
  end

  health.start("Image display capability")
  if not Snacks.config.image.enabled then
    health.info("Snacks image is disabled; terminal graphics are not required.")
  elseif #vim.api.nvim_list_uis() == 0 then
    health.info("Headless: terminal graphics cannot be verified. Run :checkhealth cfg inside the terminal you use.")
  else
    Snacks.image.terminal.detect()
    local env = Snacks.image.terminal.env()
    if env.supported then
      health.ok("Kitty graphics protocol: " .. env.name)
    else
      health.warn("Image display needs a supported terminal (Kitty / Ghostty / WezTerm). Installing ImageMagick alone is insufficient.\nSee :checkhealth snacks for terminal/tmux details.")
    end
  end

  health.start("Configured language tools (current environment and buffer)")
  local unmanaged = M.unmanaged_formatters()
  if #unmanaged > 0 then
    health.warn("Formatters without an installation source: " .. table.concat(unmanaged, ", ") .. "\nUpdate cfg.format.tools.")
  end
  health.info("Missing tools for unused languages are optional. Use project/Nix tools first, :MasonToolsInstall as an explicit fallback.\nFormatter availability may vary by buffer/project; use :ConformInfo in the affected file. Language runtimes and project dependencies still need the project's environment.")
  for _, result in ipairs(M.languages()) do
    if result.path then
      health.ok(result.feature .. ": " .. result.path)
    else
      local report = result.error and health.warn or health.info
      report("Unavailable: " .. result.feature .. " [" .. result.command .. "]" .. (result.detail and " — " .. result.detail or ""))
    end
  end
  health.info("See docs/dependencies.md for setup, build dependencies, network requirements and terminal limitations.")
end

return M
