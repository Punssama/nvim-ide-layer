local icons = require("util").icons

return {
  -- Snacks: only the small, always-useful parts. Everything else stays unloaded.
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      input = { enabled = true },
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
            { icon = "\u{f15b} ", key = "n", desc = "New File",        action = ":ene | startinsert" },
            { icon = "\u{f0c5} ", key = "g", desc = "Find Text",       action = ":FzfLua live_grep" },
            { icon = "\u{f1da} ", key = "r", desc = "Recent Files",    action = ":FzfLua oldfiles" },
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
        highlights = require("catppuccin.special.bufferline").get_theme(),
        options = {
          close_command = function(n)
            Snacks.bufdelete(n)
          end,
          right_mouse_command = function(n)
            Snacks.bufdelete(n)
          end,
          diagnostics = "nvim_lsp",
          always_show_bufferline = false,
          separator_style = "thin",
          diagnostics_indicator = function(_, _, diag)
            local ret = (diag.error and icons.diagnostics.Error .. diag.error .. " " or "")
              .. (diag.warning and icons.diagnostics.Warn .. diag.warning or "")
            return vim.trim(ret)
          end,
          offsets = {
            { filetype = "NvimTree", text = "Explorer", highlight = "Directory", text_align = "left" },
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
          theme = "catppuccin",
          globalstatus = vim.o.laststatus == 3,
          section_separators = "",
          component_separators = "",
          disabled_filetypes = { statusline = { "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
          },
          lualine_x = {
            {
              function()
                return require("noice").api.status.command.get()
              end,
              cond = function()
                return package.loaded["noice"] and require("noice").api.status.command.has()
              end,
            },
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
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {},
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
