return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      -- integrations are listed explicitly below; skipping auto-detection saves ~6ms at startup
      auto_integrations = false,
      lsp_styles = {
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
      integrations = {
        blink_cmp = true,
        dap = true,
        dap_ui = true,
        fzf = true,
        gitsigns = true,
        mason = true,
        mini = { enabled = true },
        noice = true,
        nvimtree = true,
        snacks = true,
        treesitter = true,
        lsp_trouble = true,
        which_key = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
