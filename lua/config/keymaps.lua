local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local util = require("util")

---------------------------------------------------------------------------
-- Your keymaps (ported 1:1 from Punssama/LazyvimConfig)
---------------------------------------------------------------------------

-- increment / decrement
map("n", "+", "<C-a>")
map("n", "-", "<C-x>")

-- redo
map("n", "zz", ":redo<cr>", opts)

-- buffers: <S-h> / <S-l> live in plugins/ui.lua (bufferline keys) so they lazy-load the plugin

-- delete a word backwards
map("n", "dw", 'vb"_d')

-- select all
map("n", "<C-a>", "gg<S-v>G")

-- tabs
map("n", "te", ":tabedit<cr>", opts)
map("n", "tr", ":bd<cr>", opts)

-- windows
map("n", "sd", ":split<cr>", opts)
map("n", "sn", ":vsplit<cr>", opts)
map("n", "sh", "<c-w>h")
map("n", "sl", "<c-w>l")
map("n", "sj", "<C-w>j")
map("n", "sk", "<C-w>k")
map("n", "ww", "<C-w>w")

-- resize windows
map("n", "<C-w><Right>", "<C-w>>")
map("n", "<C-w><Up>", "<C-w>+")
map("n", "<C-w><Left>", "<C-w><")
map("n", "<C-w><Down>", "<C-w>-")

-- diagnostics
map("n", "<C-j>", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next Diagnostic" })
map("n", "<C-k>", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev Diagnostic" })

-- save
map("n", "<space>w", ":w<cr>", opts)

-- file explorer: nvim-tree rooted at the current file's project
--   closed                    -> open it and focus it
--   open, cursor in editor    -> focus it (and reveal the current file)
--   open, cursor in explorer  -> close it
local function toggle_explorer()
  local api = require("nvim-tree.api")
  if not api.tree.is_visible() then
    -- open{path=} is ignored by nvim-tree, change_root works but needs native (backslash) paths on Windows
    local dir = (util.current_dir():gsub("/", vim.fn.has("win32") == 1 and "\\" or "/"))
    api.tree.open()
    if require("nvim-tree.core").get_cwd() ~= dir then
      api.tree.change_root(dir)
    end
    if vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) ~= "" then
      api.tree.find_file({ open = true, focus = true })
    end
  elseif vim.bo.filetype == "NvimTree" then
    api.tree.close()
  elseif vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) ~= "" then
    api.tree.find_file({ open = true, focus = true })
  else
    api.tree.focus()
  end
end
map("n", "<space>e", toggle_explorer, { desc = "Toggle File Explorer", noremap = true, silent = true })
map("n", "<space>fe", toggle_explorer, { desc = "Toggle File Explorer", noremap = true, silent = true })

-- terminal: toggleterm (horizontal) in the current file's project
map("n", "<space>t", function()
  require("toggleterm").toggle(1, 15, util.current_dir(), "horizontal")
end, { desc = "Toggle Terminal", noremap = true, silent = true })

-- external terminal window (Alacritty) in the current file's project
map("n", "<space>to", function()
  local bin = vim.fn.exepath("alacritty")
  vim.fn.jobstart({ bin ~= "" and bin or "alacritty", "--working-directory", util.current_dir() }, { detach = true })
end, { desc = "Open External Terminal", noremap = true, silent = true })

---------------------------------------------------------------------------
-- LazyVim-style leader map (everything that does not need a plugin)
-- Plugin-backed keys sit next to their plugin spec so pressing them lazy-loads it.
---------------------------------------------------------------------------

-- clear search highlight / save / quit
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- move lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- better indenting
map("x", "<", "<gv")
map("x", ">", ">gv")

-- search direction is always the same for n / N
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- commenting: <leader>/ toggles comments on the current line (accepts a count) or the visual selection.
-- Grep moved to <leader>sg. Uses Neovim's built-in `gc` operator, made language-aware by ts-comments.
map("n", "<leader>/", "gcc", { remap = true, desc = "Toggle Comment" })
map("x", "<leader>/", "gc", { remap = true, desc = "Toggle Comment" })
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- lists
map("n", "<leader>xl", function()
  local ok, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not ok and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })
map("n", "<leader>xq", function()
  local ok, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not ok and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })
map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- diagnostics
local diagnostic_goto = function(next, severity)
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    vim.diagnostic.jump({ count = next and 1 or -1, severity = severity, float = true })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- windows (leader split keys; <leader>w is yours: save)
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- plugin managers
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })

-- inspect
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })
map("n", "<leader>ur", "<cmd>nohlsearch<bar>diffupdate<bar>normal! <C-L><cr>", { desc = "Redraw / Clear hlsearch" })

-- toggles (Snacks.toggle needs nothing but itself, so wait for the first frame)
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
    Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
    Snacks.toggle.line_number():map("<leader>ul")
    Snacks.toggle.diagnostics():map("<leader>ud")
    Snacks.toggle.inlay_hints():map("<leader>uh")
    Snacks.toggle.treesitter():map("<leader>uT")
    Snacks.toggle({
      name = "Auto Format",
      get = function()
        return vim.g.autoformat
      end,
      set = function(state)
        vim.g.autoformat = state
      end,
    }):map("<leader>uf")
  end,
})
