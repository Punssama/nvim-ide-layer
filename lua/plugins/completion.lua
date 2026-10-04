return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      -- <CR> accepts, <Tab>/<S-Tab> jump snippets, <C-j>/<C-k> select, <C-space> open, <C-e> close
      keymap = {
        preset = "enter",
        ["<C-y>"] = { "select_and_accept" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-n>"] = false,
        ["<C-p>"] = false,
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        -- rounded frame kept; its cells get the editor background (see colorscheme.lua) so no darker
        -- rectangle shows around it. Kind icon, then label (no kind text: less noise).
        menu = {
          border = "rounded",
          scrollbar = false,
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
          },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded", scrollbar = false } },
        ghost_text = { enabled = false },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<C-j>"] = { "select_next", "fallback" },
          ["<C-k>"] = { "select_prev", "fallback" },
          ["<C-n>"] = false,
          ["<C-p>"] = false,
        },
        completion = { menu = { auto_show = true } },
      },
    },
    opts_extend = { "sources.default" },
  },
}
