-- Explicitly install this parser set with :TSInstallConfigured.
local ensure_installed = {
  -- languages in active use
  "lua",
  "python",
  "rust",
  "go",
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

    vim.api.nvim_create_user_command("TSInstallConfigured", function()
      local installed = require("nvim-treesitter").get_installed()
      local missing = vim.iter(ensure_installed)
        :filter(function(lang) return not vim.list_contains(installed, lang) end)
        :totable()
      if #missing > 0 then require("nvim-treesitter").install(missing) end
    end, { desc = "Install missing parsers from the configured language list" })

    -- no `verilog` parser on main branch; reuse systemverilog for .v files
    vim.treesitter.language.register("systemverilog", "verilog")

    local foldexpr = "v:lua.vim.treesitter.foldexpr()"
    local indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

    local function sync_folds(buf, win)
      local state = vim.b[buf]
      local windows = state.treesitter_fold_windows or {}
      local key = tostring(win)
      local opts = vim.wo[win][0]
      if state.treesitter_started and not windows[key] then
        windows[key] = { method = opts.foldmethod, expr = opts.foldexpr }
        opts.foldexpr = foldexpr
        opts.foldmethod = "expr"
      elseif not state.treesitter_started and windows[key] then
        if opts.foldexpr == foldexpr then
          if opts.foldmethod == "expr" then opts.foldmethod = windows[key].method end
          opts.foldexpr = windows[key].expr
        end
        windows[key] = nil
      else
        return
      end
      state.treesitter_fold_windows = next(windows) and windows or nil
    end

    local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      desc = "Start treesitter highlighting and folds; indent only with a query",
      callback = function(args)
        local state, opts = vim.b[args.buf], vim.bo[args.buf]
        local lang = vim.treesitter.language.get_lang(args.match)
        if opts.indentexpr == indentexpr then opts.indentexpr = "" end
        if lang and pcall(vim.treesitter.start, args.buf, lang) then
          state.treesitter_started = true
          if vim.treesitter.query.get(lang, "indents") then
            opts.indentexpr = indentexpr
          end
        elseif state.treesitter_started then
          vim.treesitter.stop(args.buf)
          state.treesitter_started = nil
        end
        for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
          sync_folds(args.buf, win)
        end
      end,
    })

    -- a buffer whose FileType fired elsewhere (background load, picker preview)
    -- still needs folds in the window that actually displays it
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = group,
      desc = "Initialize treesitter folds in each window showing the buffer",
      callback = function(args)
        local win = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_get_buf(win) == args.buf then sync_folds(args.buf, win) end
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
