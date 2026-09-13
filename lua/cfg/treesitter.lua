-- Parsers are installed on demand; every entry here is also what the
-- FileType handler below can highlight/indent/fold.
local ensure_installed = {
  -- languages in active use
  "lua",
  "python",
  "rust",
  "c",
  "cpp",
  "cuda", -- .cu has its own filetype; the c/cpp parsers do not cover it
  "haskell",
  "systemverilog",
  "javascript",
  "typescript",
  "tsx",
  -- data / config / docs
  "json",
  "yaml",
  "toml",
  "markdown",
  "markdown_inline",
  "bash",
  "vim",
  "vimdoc",
  -- small parsers that cover files this config is edited alongside of
  "diff",
  "gitcommit",
  "dockerfile",
  "make",
  "cmake",
  "sql",
  "html",
  "css",
  "nix",
  "query",
  "regex",
  "luadoc",
}

return {
  -- main branch: does not support lazy-loading
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  config = function()
    require("nvim-treesitter").setup({})

    -- install missing parsers (async, no-op if already installed)
    local installed = require("nvim-treesitter").get_installed()
    local missing = vim
      .iter(ensure_installed)
      :filter(function(lang) return not vim.list_contains(installed, lang) end)
      :totable()
    if #missing > 0 then require("nvim-treesitter").install(missing) end

    -- no `verilog` parser on main branch; reuse systemverilog for .v files
    vim.treesitter.language.register("systemverilog", "verilog")

    -- Folds are window-local options (`vim.wo[bufnr]` does not exist), so they
    -- can only be set for the window that is current when the autocmd fires.
    local function apply_folds()
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.wo.foldlevel = 99 -- start fully expanded; za/zc/zR/zM on demand
    end

    local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      desc = "Start treesitter highlighting, indent and folds",
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.b[args.buf].treesitter_started = true
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          apply_folds()
        end
      end,
    })

    -- a buffer whose FileType fired elsewhere (background load, picker preview)
    -- still needs folds in the window that actually displays it
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = group,
      desc = "Re-apply treesitter folds in every window showing the buffer",
      callback = function(args)
        if vim.b[args.buf].treesitter_started then apply_folds() end
      end,
    })

    -- textobjects (main branch: separate setup + manual keymaps)
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })

    local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
    local move = require("nvim-treesitter-textobjects.move")

    local map = function(lhs, capture, desc)
      vim.keymap.set({ "x", "o" }, lhs, function() select_textobject(capture, "textobjects") end, {
        desc = desc,
        silent = true,
      })
    end
    map("af", "@function.outer", "function outer")
    map("if", "@function.inner", "function inner")
    map("ac", "@class.outer", "class outer")
    map("ic", "@class.inner", "class inner")
    map("aa", "@parameter.outer", "parameter outer")
    map("ia", "@parameter.inner", "parameter inner")

    -- movements use captures of the same query group
    local goto_next = function(capture)
      return function() move.goto_next_start(capture, "textobjects") end
    end
    local goto_prev = function(capture)
      return function() move.goto_previous_start(capture, "textobjects") end
    end
    vim.keymap.set({ "n", "x", "o" }, "]f", goto_next("@function.outer"), { desc = "Next function start", silent = true })
    vim.keymap.set({ "n", "x", "o" }, "[f", goto_prev("@function.outer"), { desc = "Prev function start", silent = true })
  end,
}
