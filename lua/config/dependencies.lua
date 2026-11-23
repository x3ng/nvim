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

function M.resolve(command, mason)
  local path = vim.fn.exepath(command)
  if path ~= "" then return path end
  if mason then
    local candidate = vim.fn.stdpath("data") .. "/mason/bin/" .. command
    if vim.fn.executable(candidate) == 1 then return candidate end
  end
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

return M
