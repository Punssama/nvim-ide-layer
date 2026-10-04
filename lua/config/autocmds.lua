local function augroup(name)
  return vim.api.nvim_create_augroup("ide_" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- reload files changed outside of nvim
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- go to last cursor position
autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].ide_last_loc then
      return
    end
    vim.b[buf].ide_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "checkhealth",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "startuptime",
    "query",
    "dap-float",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, { buffer = event.buf, silent = true, desc = "Quit buffer" })
    end)
  end,
})

-- create missing parent directories on save
autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- wrap + spell for prose
autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

autocmd("FileType", {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Terminal padding colour: the margin around Neovim belongs to the terminal (Alacritty `window.padding`), which uses
-- its own background colour, so the editor looked inset in a darker frame. While Neovim runs, ask the terminal
-- (OSC 11) to use the colorscheme's Normal background; restore its default (OSC 111) on exit/suspend.
-- Terminals that do not understand the sequence ignore it. Nothing in alacritty.toml is touched.
local function term_bg(set)
  if #vim.api.nvim_list_uis() == 0 then
    return
  end
  local seq = "\027]111\007"
  if set then
    local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
    if not bg then
      return
    end
    seq = string.format("\027]11;#%06x\007", bg)
  end
  pcall(vim.api.nvim_chan_send, vim.v.stderr, seq)
end
autocmd({ "UIEnter", "ColorScheme", "VimResume" }, {
  group = augroup("term_bg_set"),
  callback = function()
    term_bg(true)
  end,
})
autocmd({ "VimLeave", "VimSuspend" }, {
  group = augroup("term_bg_reset"),
  callback = function()
    term_bg(false)
  end,
})

-- Right-click context menu (VS Code style). Native popup menu, so it works in any terminal with mouse
-- reporting. `mousemodel=popup_setpos` (options.lua) moves the cursor to the click first.
do
  vim.cmd("silent! aunmenu PopUp")
  local items = {
    { "n", [[Go\ to\ Definition]], "<Cmd>lua vim.lsp.buf.definition()<CR>" },
    { "n", [[Find\ References]], "<Cmd>FzfLua lsp_references<CR>" },
    { "n", [[Rename\ Symbol]], "<Cmd>lua vim.lsp.buf.rename()<CR>" },
    { "n", [[Code\ Action]], "<Cmd>lua vim.lsp.buf.code_action()<CR>" },
    { "n", [[Format\ Document]], "<Cmd>lua require('conform').format({ lsp_format = 'fallback' })<CR>" },
    { "n", "-Sep1-", "" },
    { "n", [[Toggle\ Comment]], "<Cmd>normal gcc<CR>" },
    { "v", [[Toggle\ Comment]], "<Esc><Cmd>normal gvgc<CR>" },
    { "n", "-Sep2-", "" },
    { "v", "Cut", [["+d]] },
    { "v", "Copy", [["+y]] },
    { "n", "Paste", [["+p]] },
    { "v", "Paste", [["+p]] },
    { "n", [[Select\ All]], "ggVG" },
  }
  for _, it in ipairs(items) do
    vim.cmd(("%snoremenu PopUp.%s %s"):format(it[1], it[2], it[3] ~= "" and it[3] or "<Nop>"))
  end
end

-- macro recording indicator in the statusline refreshes the moment recording starts / stops
autocmd({ "RecordingEnter", "RecordingLeave" }, {
  group = augroup("recording_refresh"),
  callback = function()
    if package.loaded["lualine"] then
      vim.schedule(function()
        require("lualine").refresh()
      end)
    end
  end,
})
