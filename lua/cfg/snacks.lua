return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    picker = {
      enabled = true,
      layout = {
        preset = "telescope",
        layout = {
          box = "horizontal",
          width = 0.9,
          height = 0.9,
          {
            box = "vertical",
            border = "rounded",
            title = "{source} {live}",
            title_pos = "center",
            { win = "input", height = 1, border = "bottom" },
            { win = "list", border = "none" },
          },
          { win = "preview", title = "{preview}", border = "rounded", width = 0.5 },
        },
      },
      sources = {
        files = { hidden = true, follow = true },
        grep = { hidden = true },
        buffers = { sort_lastused = true },
      },
    },
    explorer = { enabled = false },
    notifier = {
      enabled = true,
      timeout = 3000,
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0, right = 1, bottom = 0 },
      padding = true,
      sort = { "level", "added" },
      level = vim.log.levels.TRACE,
      icons = {
        error = " ",
        warn = " ",
        info = " ",
        debug = " ",
        trace = " ",
      },
    },
    terminal = {
      enabled = true,
      win = {
        position = "float",
        border = "rounded",
        width = 0.9,
        height = 0.8,
      },
    },
    diagnostics = {
      enabled = true,
    },
    indent = {
      enabled = true,
      animate = { enabled = false },
      scope = { enabled = true },
    },
    words = {
      enabled = true,
    },
    git = {
      enabled = true,
    },
    lazygit = {
      enabled = true,
      configure = true,
    },
    bigfile = {
      enabled = true,
      notify = false,
      size = 1.5 * 1024 * 1024,
    },
    quickfile = {
      enabled = true,
    },
    statuscolumn = {
      enabled = true,
      left = { "mark", "sign" },
      right = { "fold", "git" },
      folds = {
        open = false,
        git_hl = false,
      },
      git = {
        patterns = { "GitSign" },
      },
    },
    win = {
      enabled = true,
    },
    input = {
      enabled = true,
    },
    image = {
      enabled = true,
    },
  },
  keys = {
    -- Picker (replaces telescope)
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live Grep" },
    { "<leader>fc", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Tags" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
    { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>fm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>fj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    { "<leader>fl", function() Snacks.picker.loclist() end, desc = "Location List" },
    { "<leader>fq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>f/", function() Snacks.picker.search_history() end, desc = "Search History" },
    { "<leader>f:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
    { "<leader>fz", function() Snacks.picker.zoxide() end, desc = "Zoxide" },

    -- Terminal (replaces toggleterm)
    { "<C-\\>", function() Snacks.terminal() end, desc = "Toggle Terminal", mode = { "n", "t" } },
    { "<leader>tt", function() Snacks.terminal() end, desc = "Terminal" },
    { "<leader>th", function() Snacks.terminal({ win = { position = "bottom", height = 0.3 } }) end, desc = "Horizontal Terminal" },
    { "<leader>tv", function() Snacks.terminal({ win = { position = "right", width = 0.4 } }) end, desc = "Vertical Terminal" },

    -- Lazygit
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gG", function() Snacks.lazygit({ cwd = vim.fn.expand("%:p:h") }) end, desc = "Lazygit (file dir)" },

    -- Git
    { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
    { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff" },

    -- Diagnostics (replaces trouble)
    { "<leader>xx", function() Snacks.diagnostics.open() end, desc = "Diagnostics" },
    { "<leader>xX", function() Snacks.diagnostics.open({ bufnr = 0 }) end, desc = "Buffer Diagnostics" },
    { "<leader>cs", function() Snacks.picker.lsp_symbols() end, desc = "Symbols" },
    { "<leader>cl", function() Snacks.picker.lsp_references() end, desc = "LSP References" },

    -- Notifier (replaces fidget)
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>nd", function() Snacks.notifier.hide() end, desc = "Dismiss Notifications" },

    -- Words (LSP references highlight)
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },

    -- Scratch buffers
    { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },

    -- Profiler
    { "<leader>ps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch" },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        _G.dd = function(...) Snacks.debug.inspect(...) end
        _G.bt = function() Snacks.debug.backtrace() end
        vim.print = _G.dd
      end,
    })
  end,
}