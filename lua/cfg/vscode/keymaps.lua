-- Resolve the extension API on invocation, after its runtime has initialized.
local function map(mode, lhs, command, desc)
  vim.keymap.set(mode, lhs, function()
    require("vscode").action(command)
  end, { desc = desc, silent = true })
end

for _, binding in ipairs({
  { "<leader>w", "workbench.action.files.save", "Save" },
  { "<leader>qq", "workbench.action.closeWindow", "Close VSCode Window" },
  { "<leader>fn", "workbench.action.files.newUntitledFile", "New File" },
  { "<leader>bd", "workbench.action.closeActiveEditor", "Close Editor" },
  { "]b", "workbench.action.nextEditor", "Next Editor" },
  { "[b", "workbench.action.previousEditor", "Previous Editor" },
  { "<C-h>", "workbench.action.navigateLeft", "Window Left" },
  { "<C-j>", "workbench.action.navigateDown", "Window Down" },
  { "<C-k>", "workbench.action.navigateUp", "Window Up" },
  { "<C-l>", "workbench.action.navigateRight", "Window Right" },
  { "<leader>ff", "workbench.action.quickOpen", "Find Files" },
  { "<leader>fe", "workbench.view.explorer", "File Explorer" },
  { "<leader>fb", "workbench.action.showAllEditors", "Editors" },
  { "<leader>fg", "workbench.action.findInFiles", "Find in Files" },
  { "<leader>fc", "workbench.action.showCommands", "Commands" },
  { "<leader>fr", "workbench.action.openRecent", "Recent Files / Workspaces" },
  { "<leader>fs", "workbench.action.gotoSymbol", "Document Symbols" },
  { "<leader>fS", "workbench.action.showAllSymbols", "Workspace Symbols" },
  { "<leader>fd", "workbench.actions.view.problems", "Problems" },
  { "<leader>fk", "workbench.action.openGlobalKeybindings", "Keyboard Shortcuts" },
  { "<leader>sr", "workbench.action.replaceInFiles", "Replace in Files" },
  { "<leader>uw", "editor.action.toggleWordWrap", "Toggle Wrap" },
  { "<leader>uC", "workbench.action.selectTheme", "Color Theme" },
  { "<C-/>", "workbench.action.terminal.toggleTerminal", "Toggle Terminal" },
  { "<leader>gs", "workbench.view.scm", "Source Control" },
  { "<leader>mp", "markdown.showPreviewToSide", "Markdown Preview" },
  { "gd", "editor.action.revealDefinition", "Definition" },
  { "gD", "editor.action.revealDeclaration", "Declaration" },
  { "grr", "editor.action.goToReferences", "References" },
  { "gri", "editor.action.goToImplementation", "Implementation" },
  { "grt", "editor.action.goToTypeDefinition", "Type Definition" },
  { "grn", "editor.action.rename", "Rename" },
  { "grx", "codelens.showLensesInCurrentLine", "Code Lens" },
  { "gO", "workbench.action.gotoSymbol", "Document Symbols" },
  { "K", "editor.action.showHover", "Hover" },
  { "]d", "editor.action.marker.next", "Next Diagnostic" },
  { "[d", "editor.action.marker.prev", "Previous Diagnostic" },
  { "<leader>df", "editor.action.showHover", "Diagnostic / Hover" },
}) do
  map("n", binding[1], binding[2], binding[3])
end

map({ "n", "x" }, "gra", "editor.action.quickFix", "Code Action")
map("n", "<leader>cf", "editor.action.formatDocument", "Format Document")
-- action() forwards the current visual selection; don't leave Visual mode first.
map("x", "<leader>cf", "editor.action.formatSelection", "Format Selection")

-- UI options belong to the host, not Neovim's hidden windows.
vim.keymap.set("n", "<leader>ul", function()
  local vscode = require("vscode")
  local current = vscode.get_config("editor.lineNumbers")
  vscode.update_config("editor.lineNumbers", current == "relative" and "on" or "relative", "global")
end, { desc = "Toggle Relative Number" })
vim.keymap.set("n", "<leader>uc", function()
  local vscode = require("vscode")
  local current = vscode.get_config("editor.renderLineHighlight")
  vscode.update_config("editor.renderLineHighlight", current == "none" and "line" or "none", "global")
end, { desc = "Toggle Cursorline" })
vim.keymap.set("n", "<leader>uh", function()
  local vscode = require("vscode")
  local current = vscode.get_config("editor.inlayHints.enabled")
  vscode.update_config("editor.inlayHints.enabled", current == "off" and "on" or "off", "global")
end, { desc = "Toggle Inlay Hints" })
