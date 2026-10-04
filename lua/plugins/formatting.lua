return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = false, lsp_format = "fallback" })
        end,
        mode = { "n", "x" },
        desc = "Format",
      },
      {
        "<leader>cF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "x" },
        desc = "Format Injected Langs",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_format" },
        java = { "google-java-format" },
      },
      -- :ToggleAutoFormat lives on <leader>uf (vim.g.autoformat)
      format_on_save = function(bufnr)
        if not vim.g.autoformat or vim.b[bufnr].autoformat == false then
          return
        end
        return { timeout_ms = 3000, lsp_format = "fallback" }
      end,
    },
  },
}
