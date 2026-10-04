-- File explorer: LunarVim's nvim-tree configuration
local state = {} ---@type { opts?: table }

return {
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFileToggle", "NvimTreeFindFile" },
    init = function()
      -- netrw is replaced by nvim-tree
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      -- `nvim <dir>`: nvim-tree has to be loaded before VimEnter to hijack the directory buffer
      local arg = vim.fn.argv(0)
      if type(arg) == "string" and arg ~= "" and vim.fn.isdirectory(arg) == 1 then
        require("lazy").load({ plugins = { "nvim-tree.lua" } })
      end
    end,
    keys = {
      {
        "<leader>ug",
        function()
          local opts = state.opts
          local api = require("nvim-tree.api")
          local was_visible = api.tree.is_visible()
          local root = require("nvim-tree.core").get_cwd()
          opts.git.enable = not opts.git.enable
          require("nvim-tree").setup(opts) -- closes the tree and resets its root to the cwd
          if was_visible then
            api.tree.open()
            if root then
              api.tree.change_root(root)
            end
          end
          vim.notify("Explorer git status: " .. (opts.git.enable and "ON (slower to open)" or "OFF"))
        end,
        desc = "Toggle Explorer Git Status",
      },
    },
    config = function(_, opts)
      state.opts = opts
      require("nvim-tree").setup(opts)
    end,
    opts = function()
      local function on_attach(bufnr)
        local api = require("nvim-tree.api")

        local function bopts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        api.config.mappings.default_on_attach(bufnr)

        -- LunarVim navigation mappings
        vim.keymap.set("n", "l", api.node.open.edit, bopts("Open"))
        vim.keymap.set("n", "<CR>", api.node.open.edit, bopts("Open"))
        vim.keymap.set("n", "o", api.node.open.edit, bopts("Open"))
        vim.keymap.set("n", "h", api.node.navigate.parent_close, bopts("Close Directory"))
        vim.keymap.set("n", "v", api.node.open.vertical, bopts("Open: Vertical Split"))
        vim.keymap.set("n", "s", api.node.open.horizontal, bopts("Open: Horizontal Split"))
      end

      return {
        on_attach = on_attach,
        auto_reload_on_write = false,
        disable_netrw = false,
        hijack_cursor = false,
        hijack_netrw = true,
        hijack_unnamed_buffer_when_opening = false,
        sort_by = "name",
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        view = {
          width = 34,
          side = "left",
          preserve_window_proportions = false,
          number = false,
          relativenumber = false,
          signcolumn = "yes",
        },
        renderer = {
          add_trailing = false,
          group_empty = true,
          highlight_git = true,
          highlight_opened_files = "none",
          root_folder_label = ":~",
          indent_markers = {
            enable = true,
            icons = { corner = "\u{2514} ", edge = "\u{2502} ", none = "  " },
          },
          icons = {
            -- modern look: folder icons only, no >/v arrows
            show = { file = true, folder = true, folder_arrow = false, git = true },
            webdev_colors = true,
            git_placement = "before",
            padding = " ",
            symlink_arrow = " \u{279b} ",
            glyphs = {
              default = "\u{f021a}",
              symlink = "\u{f481}",
              folder = {
                default = "\u{e6ad}",
                empty = "\u{ea83}",
                empty_open = "\u{ea83}",
                open = "\u{e5fe}",
                symlink = "\u{f482}",
                symlink_open = "\u{e5fe}",
                arrow_open = "\u{f47c}",
                arrow_closed = "\u{f460}",
              },
              git = {
                unstaged = "\u{2717}",
                staged = "\u{2713}",
                unmerged = "\u{2325}",
                renamed = "\u{279c}",
                untracked = "\u{2605}",
                deleted = "\u{2296}",
                ignored = "\u{25cc}",
              },
            },
          },
        },
        hijack_directories = { enable = true, auto_open = true },
        -- update_root = false: the tree keeps its project root instead of re-rooting (and re-running git)
        -- every time you switch to a buffer from another folder
        update_focused_file = { enable = true, update_root = false, ignore_list = {} },
        filters = { dotfiles = false, custom = { "node_modules", "\\.cache" }, exclude = {} },
        -- git is OFF by default (toggle: <leader>ug). With it on, nvim-tree runs a synchronous `git rev-parse`
        -- for every folder it shows (60-80ms each on Windows), so opening the tree freezes Neovim for
        -- hundreds of ms. gitsigns still shows git state inside buffers.
        git = { enable = false, ignore = false, timeout = 500 },
        -- Windows: nvim-tree defaults to max_events=1000, so a busy folder (language-server caches, logs, build
        -- output, anything Defender touches) makes it spam "Observed 1001 consecutive file system events" and
        -- drop the watcher. Skip folders that churn, never raise that error, and debounce a bit longer.
        filesystem_watchers = {
          enable = true,
          debounce_delay = 100,
          max_events = 0,
          ignore_dirs = function(path)
            path = path:gsub("\\", "/")
            for _, pat in ipairs({
              "/%.git$",
              "/%.git/",
              "/node_modules",
              "/%.venv",
              "/venv$",
              "/__pycache__",
              "/%.mypy_cache",
              "/%.ruff_cache",
              "/%.pytest_cache",
              "/%.gradle",
              "/%.idea",
              "/build$",
              "/target$",
              "/out$",
              "/bin$",
              "/obj$",
              "/%.cache",
              "/nvim%-data",
              "/mason",
              "/lazy/",
              "/%.ccls%-cache",
              "/%.zig%-cache",
            }) do
              if path:find(pat) then
                return true
              end
            end
            return false
          end,
        },
        actions = {
          use_system_clipboard = true,
          change_dir = { enable = true, global = false, restrict_above_cwd = false },
          open_file = {
            quit_on_open = false,
            resize_window = false,
            window_picker = {
              enable = true,
              chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
              exclude = {
                filetype = { "notify", "lazy", "qf", "diff", "fugitive", "fugitiveblame" },
                buftype = { "nofile", "terminal", "help" },
              },
            },
          },
        },
      }
    end,
  },
}
