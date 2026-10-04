-- Everything Mason should keep installed. Names are Mason package names.
-- Need another language? :Mason, install its server and it is enabled automatically.
local mason_packages = {
  "lua-language-server",
  "pyright",
  "ruff",
  "jdtls",
  "stylua",
  "google-java-format",
  "java-debug-adapter",
  "java-test",
  "debugpy",
}

return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
    opts = { ui = { border = "rounded" } },
  },

  { "mason-org/mason-lspconfig.nvim", lazy = true },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
    config = function()
      local icons = require("util").icons.diagnostics
      local sev = vim.diagnostic.severity

      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_text = false, -- tiny-inline-diagnostic.nvim (plugins/polish.lua) draws them
        float = { border = "rounded", source = true },
        signs = {
          text = {
            [sev.ERROR] = icons.Error,
            [sev.WARN] = icons.Warn,
            [sev.HINT] = icons.Hint,
            [sev.INFO] = icons.Info,
          },
        },
      })

      vim.lsp.config("*", { capabilities = require("util").lsp_capabilities() })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
              -- keep the "Loading workspace" scan small when a Lua file is opened from a big folder
              maxPreload = 3000,
              preloadFileSize = 150,
              ignoreDir = { ".git", "node_modules", ".venv", "venv", "__pycache__", "nvim-data", "build", "target" },
            },
            codeLens = { enable = true },
            completion = { callSnippet = "Replace" },
            doc = { privateName = { "^_" } },
            hint = {
              enable = true,
              setType = false,
              paramType = true,
              paramName = "Disable",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          },
        },
      })

      -- ruff owns import sorting and lint-style diagnostics; pyright owns types
      vim.lsp.config("pyright", {
        settings = {
          pyright = { disableOrganizeImports = true },
          python = {
            analysis = { autoSearchPaths = true, useLibraryCodeForTypes = true, diagnosticMode = "openFilesOnly" },
          },
        },
      })

      -- Starting servers means spawning processes (slow, synchronous on Windows). Do it right after the
      -- first frame so the text is on screen before pyright/ruff/... boot. vim.lsp.enable() also attaches
      -- to buffers that are already open.
      -- jdtls is started by nvim-jdtls (plugins/java.lua), never by mason-lspconfig.
      vim.defer_fn(function()
        require("mason-lspconfig").setup({ automatic_enable = { exclude = { "jdtls" } } })
      end, 20)

      vim.schedule(function()
        require("util").mason_ensure(vim.deepcopy(mason_packages))
      end)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("ide_lsp_attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then
            return
          end
          if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end

          local function map(lhs, rhs, desc, mode, method)
            if method and not client:supports_method(method, ev.buf) then
              return
            end
            vim.keymap.set(mode or "n", lhs, rhs, { buffer = ev.buf, desc = desc })
          end

          local function fzf(cmd, o)
            return function()
              require("fzf-lua")[cmd](o)
            end
          end
          map("gd", fzf("lsp_definitions", { jump1 = true }), "Goto Definition", "n", "textDocument/definition")
          map(
            "gr",
            fzf("lsp_references", { jump1 = true, ignore_current_line = true }),
            "References",
            "n",
            "textDocument/references"
          )
          map(
            "gI",
            fzf("lsp_implementations", { jump1 = true }),
            "Goto Implementation",
            "n",
            "textDocument/implementation"
          )
          map("gy", fzf("lsp_typedefs", { jump1 = true }), "Goto T[y]pe Definition", "n", "textDocument/typeDefinition")
          map("gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("K", vim.lsp.buf.hover, "Hover")
          map("gK", vim.lsp.buf.signature_help, "Signature Help", "n", "textDocument/signatureHelp")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" }, "textDocument/codeAction")
          map("<leader>cA", function()
            vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
          end, "Source Action", "n", "textDocument/codeAction")
          map("<leader>cr", vim.lsp.buf.rename, "Rename", "n", "textDocument/rename")
          map("<leader>cR", function()
            Snacks.rename.rename_file()
          end, "Rename File", "n", "workspace/willRenameFiles")
          map("<leader>cc", vim.lsp.codelens.run, "Run Codelens", { "n", "x" }, "textDocument/codeLens")
          map("<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "LSP Info")
        end,
      })
    end,
  },
}
