local M = {}

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
  if #vim.api.nvim_list_uis() == 0 then
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
  health.info("Missing tools for unused languages are optional. Use project/Nix tools first, :MasonToolsInstall as an explicit fallback.\nFormatter availability may vary by buffer/project; use :ConformInfo in the affected file. Language runtimes and project dependencies still need the project's environment.")
  for _, result in ipairs(deps.languages()) do
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
