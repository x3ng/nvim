return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<C-\\>", "<cmd>ToggleTerm direction=float<CR>", desc = "Toggle floating terminal" },
    { "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", desc = "Floating terminal" },
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Vertical terminal" },
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    open_mapping = [[<C-\>]],
    direction = "float",
    start_in_insert = true,
    persist_size = true,
    persist_mode = true,
    close_on_exit = false,
    float_opts = {
      border = "rounded",
      width = function()
        return math.floor(vim.o.columns * 0.9)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.8)
      end,
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local function set_terminal_keymaps()
      local map = function(lhs, rhs, desc)
        vim.keymap.set("t", lhs, rhs, { buffer = 0, desc = desc })
      end

      map("<C-x>", [[<C-\><C-n>]], "Terminal normal mode")
      map("<C-h>", [[<Cmd>wincmd h<CR>]], "Window left")
      map("<C-j>", [[<Cmd>wincmd j<CR>]], "Window down")
      map("<C-k>", [[<Cmd>wincmd k<CR>]], "Window up")
      map("<C-l>", [[<Cmd>wincmd l<CR>]], "Window right")
    end

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = set_terminal_keymaps,
    })
  end,
}
