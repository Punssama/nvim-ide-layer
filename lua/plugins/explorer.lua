-- File explorer: LunarVim's nvim-tree configuration
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
          width = 30,
          side = "left",
          preserve_window_proportions = false,
          number = false,
          relativenumber = false,
          signcolumn = "yes",
        },
        renderer = {
          add_trailing = false,
          group_empty = false,
          highlight_git = true,
          highlight_opened_files = "none",
          root_folder_label = ":~",
          indent_markers = {
            enable = true,
            icons = { corner = "\u{2514} ", edge = "\u{2502} ", none = "  " },
          },
          icons = {
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
        update_focused_file = { enable = true, update_root = true, ignore_list = {} },
        filters = { dotfiles = false, custom = { "node_modules", "\\.cache" }, exclude = {} },
        git = { enable = true, ignore = false, timeout = 500 },
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
