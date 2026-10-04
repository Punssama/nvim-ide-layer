local o, g = vim.o, vim.g

g.mapleader = " "
g.maplocalleader = "\\"
g.autoformat = true

-- Providers we never use: probing them costs real time on Windows
for _, p in ipairs({ "python3", "ruby", "perl", "node" }) do
  g["loaded_" .. p .. "_provider"] = 0
end

vim.scriptencoding = "utf-8"
o.fileencoding = "utf-8"

-- UI
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.termguicolors = true
o.showmode = false
o.laststatus = 3
o.winborder = "rounded"
o.pumheight = 10
o.conceallevel = 2
o.list = true
o.listchars = "tab:» ,trail:·,nbsp:␣"
o.smoothscroll = true
o.winminwidth = 5
o.fillchars = table.concat({
  "foldopen:\u{f078}",
  "foldclose:\u{f054}",
  "fold: ",
  "foldsep: ",
  "diff:╱",
  "eob: ",
  "horiz:─",
  "horizup:┴",
  "horizdown:┬",
  "vert:│",
  "vertleft:┤",
  "vertright:├",
  "verthoriz:┼",
}, ",")

-- Editing (from LazyvimConfig)
o.autoindent = true
o.smartindent = true
o.smarttab = true
o.expandtab = true
o.tabstop = 2
o.shiftwidth = 2
o.shiftround = true
o.scrolloff = 10
o.sidescrolloff = 8
o.wrap = false
o.hlsearch = true
o.backup = false

-- Behaviour
o.mouse = "a"
o.confirm = true
o.ignorecase = true
o.smartcase = true
o.inccommand = "nosplit"
o.splitright = true
o.splitbelow = true
o.splitkeep = "screen"
o.virtualedit = "block"
o.jumpoptions = "view"
o.formatoptions = "jcroqlnt"
o.completeopt = "menu,menuone,noselect"
o.undofile = true
o.undolevels = 10000
o.updatetime = 200
o.timeoutlen = 300
o.foldlevel = 99
o.foldlevelstart = 99
o.shortmess = o.shortmess .. "WIcC"
o.grepprg = "rg --vimgrep"
o.grepformat = "%f:%l:%c:%m"
o.shada = "!,'100,<50,s10,h"
o.sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds"

-- Syncing the clipboard provider at startup is slow on Windows: do it after the first frame
vim.schedule(function()
  o.clipboard = "unnamedplus"
end)

-- Windows: PowerShell 7 as the :! shell (the integrated terminal uses Nushell, see plugins/terminal.lua)
if vim.fn.has("win32") == 1 and vim.fn.executable("pwsh") == 1 then
  o.shell = "pwsh"
  o.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
  o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  o.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
  o.shellquote = ""
  o.shellxquote = ""
end
