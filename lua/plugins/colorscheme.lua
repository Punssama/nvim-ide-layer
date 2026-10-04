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
        treesitter_context = true,
        rainbow_delimiters = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      -- UI colours (borders, explorer, terminal, tabs) are derived from whichever theme is active
      local T = require("util.theme")
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("ide_theme_ui", { clear = true }),
        callback = T.apply_ui,
      })
      T.apply_saved()
    end,
  },

  -- extra themes: loaded on demand by util/theme.lua (picker: <leader>uC)
  { "folke/tokyonight.nvim", lazy = true, opts = { styles = { sidebars = "dark", floats = "dark" } } },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "EdenEast/nightfox.nvim", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "sainnhe/everforest", lazy = true, init = function() vim.g.everforest_background = "medium" end },
  { "olimorris/onedarkpro.nvim", lazy = true },
  { "Mofiqul/dracula.nvim", lazy = true },
}
