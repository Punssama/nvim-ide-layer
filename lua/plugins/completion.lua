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
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded", scrollbar = false },
          -- pyright / lua_ls send the signature as a ```lang fenced block; rendered as markdown, the fence rows stay
          -- behind as blank lines (concealed, not removed). Show that code as the highlighted detail part instead.
          draw = function(opts)
            local doc = opts.item.documentation
            local value = type(doc) == "table" and doc.value or doc
            if type(value) ~= "string" then
              return opts.default_implementation()
            end
            local code, rest = value:match("^%s*```[%w_+-]*\r?\n(.-)\r?\n```(.*)$")
            if not code then
              return opts.default_implementation()
            end
            rest = rest:gsub("^%s*%-%-%-+", ""):gsub("^%s+", "")
            local detail = { code }
            if type(opts.item.detail) == "string" and opts.item.detail ~= "" then
              table.insert(detail, 1, opts.item.detail)
            end
            opts.default_implementation({
              detail = detail,
              documentation = rest ~= "" and { kind = "markdown", value = rest } or false,
            })
          end,
        },
        ghost_text = { enabled = false },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
          -- after a trigger character (obj. / ->) only members make sense; snippets there are noise
          snippets = {
            should_show_items = function(ctx)
              return ctx.trigger.initial_kind ~= "trigger_character"
            end,
          },
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
