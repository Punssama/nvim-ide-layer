local icons = require("util").icons

return {
  -- Snacks: only the small, always-useful parts. Everything else stays unloaded.
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    keys = {
      { "<leader>uz", function() Snacks.zen() end, desc = "Zen Mode" },
      { "<leader>uZ", function() Snacks.zen.zoom() end, desc = "Zoom Window" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss Notifications" },
      { "<leader>sN", function() Snacks.notifier.show_history() end, desc = "Notification History" },
      { "]r", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
      { "[r", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
    },
    opts = {
      -- soft highlight of the other uses of the symbol under the cursor (LSP references)
      words = { enabled = true, debounce = 200 },
      zen = { enabled = true, toggles = { dim = false } },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      input = { enabled = true },
      -- smooth, short scroll animation (Ctrl-d/u, Ctrl-f/b, zz ...) instead of jumping
      scroll = { enabled = true, animate = { duration = { step = 8, total = 120 }, easing = "outQuad" } },
      notifier = { enabled = true, timeout = 3000 },
      indent = {
        enabled = true,
        animate = { enabled = false },
        scope = { enabled = true },
      },
      dashboard = {
        enabled = true,
        preset = {
          header = table.concat({
            "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
            "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
            "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
            "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
            "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
            "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
          }, "\n"),
          -- stylua: ignore
          keys = {
            { icon = "\u{f002} ", key = "f", desc = "Find File",       action = ":FzfLua files" },
            { icon = "\u{f017} ", key = "r", desc = "Recent Files",    action = ":FzfLua oldfiles" },
            { icon = "\u{f0c5} ", key = "g", desc = "Find Word",       action = ":FzfLua live_grep" },
            { icon = "\u{f15b} ", key = "n", desc = "New File",        action = ":ene | startinsert" },
            { icon = "\u{f11c} ", key = "m", desc = "Mappings",        action = ":FzfLua keymaps" },
            { icon = "\u{e615} ", key = "c", desc = "Config",          action = ":FzfLua files cwd=" .. vim.fn.stdpath("config") },
            { icon = "\u{e62d} ", key = "s", desc = "Restore Session", action = function() require("persistence").load() end },
            { icon = "\u{f0e8} ", key = "e", desc = "File Explorer",   action = ":NvimTreeOpen" },
            { icon = "\u{f0fa} ", key = "l", desc = "Lazy",            action = ":Lazy" },
            { icon = "\u{f426} ", key = "q", desc = "Quit",            action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },

  -- Icons (also stands in for nvim-web-devicons)
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  { "MunifTanjim/nui.nvim", lazy = true },

  -- Buffer tabs
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer", silent = true },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer", silent = true },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move Buffer Prev" },
      { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move Buffer Next" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle Pin" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Delete Non-Pinned Buffers" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Delete Buffers to the Right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Delete Buffers to the Left" },
      { "<leader>bj", "<cmd>BufferLinePick<cr>", desc = "Pick Buffer" },
    },
    opts = function()
      return {
        -- "island" tabs, colours derived from the active theme (re-evaluated on every ColorScheme event)
        highlights = function(defaults)
          return vim.tbl_deep_extend("force", defaults.highlights or {}, require("util.theme").bufferline())
        end,
        options = {
          close_command = function(n)
            Snacks.bufdelete(n)
          end,
          right_mouse_command = function(n)
            Snacks.bufdelete(n)
          end,
          -- island tabs: rounded caps (the cap colour comes from the separator_* highlights above), a close icon
          -- on each tab, a dot for unsaved buffers; diagnostics live in the statusline instead
          diagnostics = false,
          always_show_bufferline = true,
          themable = false, -- some themes (Dracula...) ship their own BufferLine* groups; ours must win
          separator_style = { "\u{e0b6}", "\u{e0b4}" },
          indicator = { style = "none" },
          buffer_close_icon = "\u{f0156}",
          modified_icon = "\u{25cf}",
          show_buffer_close_icons = true,
          show_close_icon = false,
          tab_size = 18,
          max_name_length = 24,
          offsets = {
            { filetype = "NvimTree", text = "File Explorer", highlight = "NvimTreeRootFolder", text_align = "center", separator = false },
          },
        },
      }
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- placeholder until lualine loads, avoids a flash of the default statusline
        vim.o.statusline = " "
      else
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      vim.o.laststatus = vim.g.lualine_laststatus
      return {
        options = {
          -- explicit: "auto" scans every plugin's runtimepath for a matching theme
          theme = "ide", -- lua/lualine/themes/ide.lua, built from the active colorscheme
          globalstatus = vim.o.laststatus == 3,
          section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
          component_separators = "",
          disabled_filetypes = { statusline = { "snacks_dashboard" } },
        },
        -- NvChad "default" statusline: mode block | file + git | ... | diagnostics, LSP, cwd, cursor block
        sections = {
          lualine_a = {
            { "mode", icon = "\u{e7c5}", padding = { left = 1, right = 1 } },
          },
          lualine_b = {},
          lualine_c = {
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            {
              "filename",
              path = 0,
              symbols = { modified = " \u{25cf}", readonly = " \u{f023}", unnamed = "" },
              -- terminal buffers are named "5468:nu:#toggleterm#1": show a plain label instead
              fmt = function(str)
                return vim.bo.buftype == "terminal" and "Terminal" or str
              end,
            },
            { "branch", icon = "\u{e725}" },
            {
              "diff",
              symbols = { added = icons.git.added, modified = icons.git.modified, removed = icons.git.removed },
              source = function()
                local g = vim.b.gitsigns_status_dict
                if g then
                  return { added = g.added, modified = g.changed, removed = g.removed }
                end
              end,
            },
          },
          lualine_x = {
            { "searchcount", maxcount = 999, timeout = 500 },
            {
              function()
                return "\u{f044a} @" .. vim.fn.reg_recording()
              end,
              cond = function()
                return vim.fn.reg_recording() ~= ""
              end,
              color = function()
                return { fg = require("util.theme").hex(require("util.theme").palette().red) }
              end,
            },
            {
              function()
                return require("noice").api.status.command.get()
              end,
              cond = function()
                return package.loaded["noice"] and require("noice").api.status.command.has()
              end,
            },
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            {
              function()
                local names = {}
                for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                  names[#names + 1] = c.name
                end
                return #names > 0 and ("\u{f013} " .. table.concat(names, ", ")) or ""
              end,
            },
          },
          lualine_y = {
            {
              function()
                return "\u{f024b} " .. vim.fs.basename(vim.uv.cwd() or "")
              end,
            },
          },
          lualine_z = {
            { "progress", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 1, right = 1 } },
          },
        },
        extensions = { "nvim-tree", "trouble" },
      }
    end,
  },

  -- Prettier cmdline / messages / LSP docs
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      lsp = {
        -- jdtls reports "Validate documents" / "Publish Diagnostics" on every keystroke; as popups that is pure noise
        progress = { enabled = false },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = { { find = "%d+L, %d+B" }, { find = "; after #%d+" }, { find = "; before #%d+" } },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
  },

  -- Keymap hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        {
          mode = { "n", "x" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>a", group = "ai/claude" },
          { "<leader>b", group = "buffer" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "hunks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui" },
          { "<leader>x", group = "diagnostics/quickfix" },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
        },
        {
          "<leader>?",
          function()
            require("which-key").show({ global = false })
          end,
          desc = "Buffer Keymaps (which-key)",
        },
      },
    },
  },

  -- Sessions
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session",
      },
      {
        "<leader>qS",
        function()
          require("persistence").select()
        end,
        desc = "Select Session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },
}
