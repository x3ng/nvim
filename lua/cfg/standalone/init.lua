require("cfg.standalone.options")
require("cfg.standalone.keymaps")
require("cfg.standalone.theme")
-- Register native LSP before Mason changes PATH.
require("cfg.lsp")
require("cfg.format.cpp-indent").setup()
