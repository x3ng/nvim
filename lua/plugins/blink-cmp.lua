return {
  "Saghen/blink.cmp",
  dependencies = {
    "xzbdmw/colorful-menu.nvim",
    "rafamadriz/friendly-snippets",
    "folke/lazydev.nvim",
  },
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  opts = {
    -- Keep completion usable without downloading or building a native matcher.
    fuzzy = { implementation = "lua" },
    -- Built-in preset: Enter accepts a selected candidate; Ctrl-n/p select.
    keymap = { preset = "enter" },

    completion = {
      list = { selection = { preselect = false } },
      documentation = { auto_show = true },
      menu = {
        border = "rounded",
        draw = {
          columns = { { "kind_icon" }, { "label", gap = 1 } },
          components = {
            label = {
              text = function(ctx) return require("colorful-menu").blink_components_text(ctx) end,
              highlight = function(ctx) return require("colorful-menu").blink_components_highlight(ctx) end,
            },
          },
        },
      },
    },
    signature = {
      enabled = true,
    },
    cmdline = {
      keymap = { preset = "cmdline" },
      completion = {
        list = { selection = { preselect = false } },
        menu = {
          auto_show = true,
        },
      },
    },
    sources = {
      default = { "lazydev", "lsp", "path", "snippets", "buffer" },
      providers = {
        lazydev = {
          name = "lazydev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
      },
    },
  },
  opts_extend = { "sources.default" },
}
