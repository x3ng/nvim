-- Reuse Snacks' cwd/count identity across layouts; changing the presentation
-- must not start another shell or toggle a window in the old position.
local function terminal(position)
  local layout = {
    float = { position = "float", width = 0.9, height = 0.8 },
    bottom = { position = "bottom", width = 0.9, height = 0.3 },
    right = { position = "right", width = 0.4, height = 0.8 },
  }
  local win = layout[position]
  local term, created = Snacks.terminal.get(nil, { win = win })
  if created then return end
  if term.opts.position == position then
    term:toggle()
  else
    term:hide()
    term.opts = vim.tbl_deep_extend("force", term.opts, win)
    term:show():focus()
  end
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    picker = {
      enabled = true,
      win = {
        input = {
          keys = {
            -- In Insert, inherit Readline text editing instead of picker actions.
            -- Keep the original actions available in Normal mode.
            ["<c-a>"] = { "select_all", mode = "n" },
            ["<c-b>"] = { "preview_scroll_up", mode = "n" },
            ["<c-d>"] = { "list_scroll_down", mode = "n" },
            ["<c-f>"] = { "preview_scroll_down", mode = "n" },
            ["<c-k>"] = { "list_up", mode = "n" },
            ["<c-u>"] = { "list_scroll_up", mode = "n" },
            ["<a-d>"] = { "inspect", mode = "n" },
            ["<a-f>"] = { "toggle_follow", mode = "n" },
          },
        },
      },
      layout = {
        -- no `preset` here: snacks skips preset resolution as soon as a custom
        -- `layout` is given, so a preset next to it is dead config
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
        colorschemes = {
          -- Keep preview changes out of persistence and restore synchronously
          -- on close, so queued preview/restore callbacks cannot race a choice.
          preview = function(ctx)
            local picker = ctx.picker
            picker.user_theme = picker.user_theme or { name = vim.g.colors_name or "default", background = vim.o.background }
            require("cfg.standalone.theme").preview(ctx.item.text)
            Snacks.picker.preview.file(ctx)
          end,
          on_close = function(picker)
            local original = picker.user_theme
            if original then require("cfg.standalone.theme").preview(original.name, original.background) end
          end,
          confirm = function(picker, item)
            picker:close()
            if item then vim.cmd.colorscheme(item.text) end
          end,
        },
        -- Navigation should include files regardless of Git ignore rules.
        files = { hidden = true, ignored = true, follow = true },
        explorer = {
          hidden = true,
          ignored = true,
          follow = true,
          exclude = { ".git" },
          auto_close = true,
          jump = { close = true },
          -- Replace the global two-column layout: the tree gets the full width,
          -- with an optional preview below it for narrow tmux panes.
          layout = function()
            return {
              preview = false,
              layout = {
                box = "vertical",
                width = 0.9,
                height = 0.85,
                border = "rounded",
                title = "{title}",
                title_pos = "center",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
                { win = "preview", height = 0.4, border = "top" },
              },
            }
          end,
        },
        grep = { hidden = true },
        buffers = { sort_lastused = true },
      },
    },
    explorer = { enabled = true },
    dashboard = {
      enabled = true,
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { title = "Recent", section = "recent_files", limit = 6, padding = 1 },
        { title = "Projects", section = "projects", limit = 6, padding = 1 },
        -- restored from persistence.nvim (see cfg/plugins/persistence.lua)
        { title = "Sessions", section = "session", padding = 1 },
        { section = "startup" },
      },
    },
    notifier = {
      enabled = true,
      timeout = 3000,
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0, right = 1, bottom = 0 },
      padding = true,
      sort = { "level", "added" },
      level = vim.log.levels.INFO,
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
        width = 0.9,
        height = 0.8,
        wo = { winbar = "" },
      },
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
    },
    win = {
      enabled = true,
    },
    input = {
      enabled = true,
      win = {
        keys = {
          i_ctrl_p = { "<c-p>", "hist_up", mode = "i" },
          i_ctrl_n = { "<c-n>", "hist_down", mode = "i" },
        },
      },
    },
    image = { enabled = true },
  },
  keys = {
    -- Buffers and scratch
    { "<leader>bb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer (keep layout)" },
    { "<leader>bs", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>bS", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    -- Theme picking needs a picker, so it lives here instead of in the
    -- plugin-free base layer (see cfg/standalone/theme.lua)
    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Choose Colorscheme" },

    -- Files and projects
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fe", function() Snacks.explorer() end, desc = "File Explorer" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },

    -- Search and pick
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Live Grep" },
    { "<leader>sc", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Tags" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>s/", function() Snacks.picker.search_history() end, desc = "Search History" },
    { "<leader>s:", function() Snacks.picker.command_history() end, desc = "Command History" },

    -- Terminals
    { "<C-/>", function() terminal("float") end, desc = "Toggle Terminal", mode = { "n", "t" } },
    { "<leader>th", function() terminal("bottom") end, desc = "Horizontal Terminal" },
    { "<leader>tv", function() terminal("right") end, desc = "Vertical Terminal" },

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

    -- Message routing/history and dismiss mappings belong to Noice.

    -- Words (LSP references highlight)
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
  },
}
