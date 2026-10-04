return {
  -- Git signs + hunk actions
  {
    "lewis6991/gitsigns.nvim",
    -- after the first frame: gitsigns attaches to already-open buffers when it loads
    event = "VeryLazy",
    opts = {
      signs = {
        add = { text = "\u{258e}" },
        change = { text = "\u{258e}" },
        delete = { text = "\u{f0d7}" },
        topdelete = { text = "\u{f0d8}" },
        changedelete = { text = "\u{258e}" },
        untracked = { text = "\u{258e}" },
      },
      signs_staged = {
        add = { text = "\u{258e}" },
        change = { text = "\u{258e}" },
        delete = { text = "\u{f0d7}" },
        topdelete = { text = "\u{f0d8}" },
        changedelete = { text = "\u{258e}" },
      },
      -- Windows: fewer git subprocess calls = no micro-lag while typing
      update_debounce = 300,
      max_file_length = 10000,
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },

  -- Diagnostics / quickfix / symbols list
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = { modes = { lsp = { win = { position = "right" } } } },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP References/Definitions (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
  },

  -- TODO / FIXME / NOTE highlighting
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next Todo Comment",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous Todo Comment",
      },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
      {
        "<leader>xT",
        "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
        desc = "Todo/Fix/Fixme (Trouble)",
      },
      {
        "<leader>st",
        function()
          require("todo-comments.fzf").todo()
        end,
        desc = "Todo",
      },
    },
  },

  -- Pairs, surround, text objects, comments
  {
    "nvim-mini/mini.pairs",
    event = "InsertEnter",
    opts = { modes = { insert = true, command = false, terminal = false } },
  },
  {
    "nvim-mini/mini.surround",
    keys = function(_, keys)
      local mappings = {
        { "gsa", desc = "Add Surrounding", mode = { "n", "x" } },
        { "gsd", desc = "Delete Surrounding" },
        { "gsf", desc = "Find Right Surrounding" },
        { "gsF", desc = "Find Left Surrounding" },
        { "gsh", desc = "Highlight Surrounding" },
        { "gsr", desc = "Replace Surrounding" },
        { "gsn", desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_map(function(m)
        m.mode = m.mode or "n"
        return m
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    },
  },
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          d = { "%f[%d]%d+" },
          u = ai.gen_spec.function_call(),
          g = function()
            local from = { line = 1, col = 1 }
            local last = vim.fn.line("$")
            local to = { line = last, col = math.max(vim.fn.getline(last):len(), 1) }
            return { from = from, to = to }
          end,
        },
      }
    end,
  },
  { "folke/ts-comments.nvim", event = "VeryLazy", opts = {} },

  -- Lua LS knows about the Neovim API while editing this config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "lazy" } },
      },
    },
  },
}
