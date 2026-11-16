-- Non-language dependencies live here. This reports availability, never installs.
-- Each `any` entry is an alternative; all commands in one alternative are needed.
local M = {}

M.tools = {
  { id = "git", feature = "Git / plugin installation", any = { { "git" } }, startup = true, nix = "git" },
  { id = "search", feature = "Live grep / TODO search / project replacement", any = { { "rg" } }, startup = true, nix = "ripgrep" },
  { id = "files", feature = "File picker", any = { { "fd" }, { "fdfind" }, { "rg" }, { "find" } }, startup = true, nix = "fd" },
  { id = "lazygit", feature = "Lazygit TUI", any = { { "lazygit" } }, startup = true, nix = "lazygit" },
  { id = "image", feature = "Image conversion (non-PNG)", any = { { "magick" }, { "convert" } }, startup = true, nix = "imagemagick" },
  { id = "node", feature = "Markdown browser preview runtime", any = { { "node" } }, startup = true, nix = "nodejs" },
  { id = "curl", feature = "Downloads / remote images / parser installation", any = { { "curl" } }, startup = true, nix = "curl" },
  { id = "clipboard", feature = "System clipboard", any = { { "wl-copy", "wl-paste" }, { "xclip" }, { "xsel" } }, optional = true, nix = "wl-clipboard" },
  { id = "input-method", feature = "Input method switching", any = { { "fcitx5-remote" } }, optional = true, nix = "fcitx5" },
  { id = "tree-sitter", feature = "Parser installation / update", any = { { "tree-sitter" } }, min_version = "0.26.1", nix = "tree-sitter" },
  { id = "compiler", feature = "Parser compilation", any = { { "cc" }, { "gcc" }, { "clang" } }, nix = "gcc" },
  { id = "tar", feature = "Parser installation", any = { { "tar" } }, nix = "gnutar" },
  { id = "npm", feature = "Markdown preview plugin build (npm install)", any = { { "npm" } }, nix = "nodejs" },
  { id = "pdf", feature = "PDF image preview", any = { { "gs" } }, optional = true, nix = "ghostscript" },
  { id = "latex", feature = "LaTeX math images", any = { { "tectonic" }, { "pdflatex" } }, optional = true, nix = "tectonic" },
  { id = "typst", feature = "Typst math images", any = { { "typst" } }, optional = true, nix = "typst" },
  { id = "mermaid", feature = "Mermaid images", any = { { "mmdc" } }, optional = true, nix = "mermaid-cli" },
  { id = "video", feature = "Video thumbnails", any = { { "ffmpeg" } }, optional = true, nix = "ffmpeg" },
  { id = "cpp-indent", feature = "C/C++ project indentation", any = { { "clang-format" } }, optional = true, nix = "clang-tools" },
}

function M.resolve(command)
  local path = vim.fn.exepath(command)
  return path ~= "" and path or nil
end

function M.inspect(resolve, versions)
  resolve = resolve or M.resolve
  local results = {}
  for _, tool in ipairs(M.tools) do
    local result = { tool = tool, paths = {}, available = false }
    for _, alternative in ipairs(tool.any) do
      local paths = {}
      for _, command in ipairs(alternative) do
        local path = resolve(command)
        if path then paths[#paths + 1] = path end
      end
      if #paths == #alternative then
        result.paths, result.available = paths, true
        break
      end
    end
    if result.available and versions and tool.min_version then
      local output = vim.system({ result.paths[1], "--version" }, { text = true }):wait(1500)
      local version = vim.version.parse(output.stdout or "")
      result.available = output.code == 0 and version ~= nil and vim.version.ge(version, tool.min_version)
      result.detail = result.available and ("version " .. tostring(version)) or ("requires >= " .. tool.min_version .. "; version check failed or too old")
    end
    results[#results + 1] = result
  end
  return results
end

function M.requirement(tool)
  local alternatives = {}
  for _, commands in ipairs(tool.any) do alternatives[#alternatives + 1] = table.concat(commands, " + ") end
  return table.concat(alternatives, " OR ")
end

function M.hint(tool)
  return "Project nix develop, or: nix shell nixpkgs#" .. tool.nix .. " -c nvim"
end

-- Reuse the configured language registries instead of another executable list.
-- Called only by explicit health checks, so startup does not load Conform.
function M.languages()
  local results = {}
  for name, config in pairs(require("cfg.lsp.servers")) do
    local command = config.cmd[1]
    local path = M.resolve(command)
    local mason_path = vim.fn.stdpath("data") .. "/mason/bin/" .. command
    if not path and vim.fn.executable(mason_path) == 1 then path = mason_path end
    results[#results + 1] = { feature = "LSP " .. name, command = command, path = path }
  end
  local conform = require("conform")
  local names = {}
  for _, formatters in pairs(require("cfg.format.conform").opts.formatters_by_ft) do
    for _, name in ipairs(formatters) do names[name] = true end
  end
  for name in pairs(names) do
    local info = conform.get_formatter_info(name)
    results[#results + 1] = {
      feature = "Formatter " .. name, command = info.command,
      path = info.available and M.resolve(info.command) or nil, detail = info.available_msg, error = info.error,
    }
  end
  table.sort(results, function(a, b) return a.feature < b.feature end)
  return results
end

function M.notify_missing(results, terminal)
  local missing = {}
  for _, result in ipairs(results) do
    if result.tool.startup and not result.available then
      missing[#missing + 1] = M.requirement(result.tool) .. " → " .. result.tool.feature
    end
  end
  if terminal == false then missing[#missing + 1] = "Kitty graphics protocol → image display unavailable in this terminal" end
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
        local results = M.inspect()
        Snacks.image.terminal.detect(function()
          M.notify_missing(results, Snacks.image.terminal.env().supported == true)
        end)
      end)
    end,
  })
end

return M
