local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

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
    keymap = {
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-u>"] = false,
      ["<C-d>"] = false,
      ["<C-e>"] = false,
      ["<C-b>"] = false,
      ["<C-f>"] = false,
      ["<C-n>"] = false,
      ["<C-p>"] = false,
      ["<C-k>"] = false,
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = {
        "snippet_forward",
        "select_next",
        function(cmp)
          if has_words_before() or vim.api.nvim_get_mode().mode == "c" then return cmp.show() end
        end,
        "fallback",
      },
      ["<S-Tab>"] = {
        "select_prev",
        "snippet_backward",
        function(cmp)
          if vim.api.nvim_get_mode().mode == "c" then return cmp.show() end
        end,
        "fallback",
      },
    },

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
      keymap = {
        preset = "cmdline",
        ["<C-a>"] = false, ["<C-e>"] = false,
        ["<C-b>"] = false, ["<C-f>"] = false,
        ["<C-d>"] = false, ["<C-k>"] = false,
        ["<C-n>"] = false, ["<C-p>"] = false,
        ["<C-u>"] = false,
      },
      completion = {
        list = { selection = { preselect = false } },
        menu = {
          auto_show = true,
        },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
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
