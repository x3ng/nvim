local ensure_installed = {
  "lua",
  "python",
  "rust",
  "c",
  "cpp",
  "haskell",
  "markdown",
  "markdown_inline",
  "systemverilog",
  "json",
  "yaml",
  "toml",
  "bash",
  "vim",
  "vimdoc",
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

    local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      desc = "Start treesitter highlighting, indent and folds",
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.wo[0][0].foldmethod = "expr"
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldlevel = 99 -- start fully expanded; za/zc/zR/zM on demand
        end
      end,
    })

    -- textobjects (main branch: separate setup + manual keymaps)
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
    })
    local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
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
  end,
}
