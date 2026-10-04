-- Parsers to have from day one. Any other language is installed on first open.
local ensure = {
  "bash",
  "c",
  "cpp",
  "css",
  "diff",
  "gitcommit",
  "gitignore",
  "html",
  "java",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall", "TSUninstall", "TSLog" },
    config = function()
      local TS = require("nvim-treesitter")

      -- The tree-sitter CLI is an MSVC build: it only looks for cl.exe unless CC is set explicitly.
      -- Parsers are compiled with gcc (MSYS2) when MSVC is not installed.
      if vim.env.CC == nil and vim.fn.executable("cl") == 0 and vim.fn.executable("gcc") == 1 then
        vim.env.CC = "gcc"
      end

      TS.setup({})

      local installed = {} ---@type table<string, boolean>
      local function refresh()
        installed = {}
        for _, lang in ipairs(TS.get_installed("parsers")) do
          installed[lang] = true
        end
      end
      refresh()

      local missing = vim.tbl_filter(function(lang)
        return not installed[lang]
      end, ensure)
      if #missing > 0 then
        TS.install(missing, { summary = true }):await(refresh)
      end

      local available ---@type table<string, boolean>?
      local tried = {} ---@type table<string, boolean>

      local function start(buf, lang)
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        if pcall(vim.treesitter.start, buf, lang) and vim.treesitter.query.get(lang, "indents") then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ide_treesitter", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang then
            return
          end
          if installed[lang] then
            return start(ev.buf, lang)
          end
          if tried[lang] then
            return
          end
          tried[lang] = true
          if not available then
            available = {}
            for _, l in ipairs(TS.get_available()) do
              available[l] = true
            end
          end
          if available[lang] then
            TS.install({ lang }):await(function()
              refresh()
              vim.schedule(function()
                if installed[lang] then
                  start(ev.buf, lang)
                end
              end)
            end)
          end
        end,
      })
    end,
  },

  -- @function / @class / @parameter ... queries (used by mini.ai) and motions
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter-textobjects").setup({ move = { set_jumps = true } })
      local keys = {
        goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
        goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
        goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
      }
      for method, maps in pairs(keys) do
        for lhs, query in pairs(maps) do
          vim.keymap.set({ "n", "x", "o" }, lhs, function()
            if vim.wo.diff and lhs:find("[cC]") then
              return vim.cmd("normal! " .. lhs)
            end
            require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
          end, { silent = true, desc = (lhs:sub(1, 1) == "[" and "Prev " or "Next ") .. query:gsub("@", "") })
        end
      end
    end,
  },

  { "windwp/nvim-ts-autotag", event = "VeryLazy", opts = {} },
}
