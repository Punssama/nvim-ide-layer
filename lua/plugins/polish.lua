-- UI/UX polish: sticky scope header, prettier inline diagnostics, rainbow brackets, label-jump motion.
return {
  -- keeps the signature of the current class/method pinned at the top while scrolling (like VS Code sticky scroll)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      {
        "<leader>ut",
        function() require("treesitter-context").toggle() end,
        desc = "Toggle Sticky Context",
      },
    },
    opts = { max_lines = 3, multiline_threshold = 1, trim_scope = "outer", mode = "cursor" },
  },

  -- one-line diagnostic with icon/colour under the cursor line, instead of the default virtual text
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    opts = {
      preset = "modern",
      options = {
        show_source = { enabled = true, if_many = true },
        multilines = { enabled = true, always_show = false },
        break_line = { enabled = true, after = 60 },
        throttle = 40,
      },
    },
  },

  -- coloured nested brackets (treesitter based)
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "rainbow-delimiters.setup",
    opts = {},
  },

  -- jump anywhere in 2-3 keys: s{char}{label}, S = pick a treesitter node
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { search = { enabled = false }, char = { enabled = false } } },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
  },
}
