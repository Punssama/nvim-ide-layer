-- Integrated terminal: LunarVim's toggleterm configuration (Nushell when available)
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = {
      "ToggleTerm",
      "ToggleTermSetName",
      "ToggleTermToggleAll",
      "ToggleTermSendVisualLines",
      "ToggleTermSendCurrentLine",
    },
    keys = {
      { [[<C-\>]], "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
      {
        "<leader>gg",
        function()
          if vim.fn.executable("lazygit") ~= 1 then
            return vim.notify("lazygit is not installed", vim.log.levels.WARN)
          end
          local Terminal = require("toggleterm.terminal").Terminal
          Terminal:new({ cmd = "lazygit", dir = require("util").root(), direction = "float", hidden = true }):toggle()
        end,
        desc = "Lazygit",
      },
    },
    -- a function so vim.fn.executable("nu") (~5ms on Windows) only runs when toggleterm loads
    opts = function()
      -- same panel colour as the explorer (mantle) instead of toggleterm's computed "shade"
      return {
        highlights = require("util.theme").toggleterm_highlights(),
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
          return 20
        end,
        open_mapping = [[<C-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = false,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = false,
        direction = "horizontal",
        close_on_exit = true,
        shell = vim.fn.executable("nu") == 1 and "nu" or vim.o.shell,
        float_opts = {
          border = "curved",
          winblend = 0,
          highlights = { border = "Normal", background = "Normal" },
        },
        winbar = {
          enabled = true,
          name_formatter = function(term)
            local dir = term.dir or vim.fn.getcwd()
            return " \u{f489}  Terminal \u{00b7} " .. vim.fn.fnamemodify(dir, ":t") .. " "
          end,
        },
      }
    end,
    config = function(_, opts)
      require("toggleterm").setup(opts)
      -- winbar title colours (WinBarActive/Inactive) are set by util.theme.apply_ui on every colorscheme change
      require("util.theme").apply_ui()
      -- LunarVim terminal-mode navigation, only inside toggleterm buffers
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*toggleterm#*",
        callback = function(ev)
          local o = { buffer = ev.buf }
          vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], o)
          vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], o)
          vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], o)
          vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], o)
          vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], o)
        end,
      })
    end,
  },
}
