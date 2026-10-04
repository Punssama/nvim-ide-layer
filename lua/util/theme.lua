-- Theme manager: a list of colorschemes, a live-preview picker, persistence, and a palette derived from the
-- active scheme's own highlight groups so every UI plugin (explorer, tabs, statusline, terminal, popups)
-- follows whichever theme is selected.
local M = {}

-- name shown in the picker -> how to load it
M.themes = {
  { "Catppuccin Mocha", plugin = "catppuccin", cs = "catppuccin", setup = { flavour = "mocha" } },
  { "Catppuccin Macchiato", plugin = "catppuccin", cs = "catppuccin", setup = { flavour = "macchiato" } },
  { "Catppuccin Frappe", plugin = "catppuccin", cs = "catppuccin", setup = { flavour = "frappe" } },
  { "Catppuccin Latte (light)", plugin = "catppuccin", cs = "catppuccin", setup = { flavour = "latte" }, bg = "light" },
  { "Tokyo Night", plugin = "tokyonight.nvim", cs = "tokyonight-night" },
  { "Tokyo Night Storm", plugin = "tokyonight.nvim", cs = "tokyonight-storm" },
  { "Tokyo Night Moon", plugin = "tokyonight.nvim", cs = "tokyonight-moon" },
  { "Rose Pine", plugin = "rose-pine", cs = "rose-pine-main" },
  { "Rose Pine Moon", plugin = "rose-pine", cs = "rose-pine-moon" },
  { "Rose Pine Dawn (light)", plugin = "rose-pine", cs = "rose-pine-dawn", bg = "light" },
  { "Kanagawa Wave", plugin = "kanagawa.nvim", cs = "kanagawa-wave" },
  { "Kanagawa Dragon", plugin = "kanagawa.nvim", cs = "kanagawa-dragon" },
  { "Nightfox", plugin = "nightfox.nvim", cs = "nightfox" },
  { "Carbonfox", plugin = "nightfox.nvim", cs = "carbonfox" },
  { "Nordfox", plugin = "nightfox.nvim", cs = "nordfox" },
  { "Gruvbox Dark", plugin = "gruvbox.nvim", cs = "gruvbox", bg = "dark" },
  { "Gruvbox Light", plugin = "gruvbox.nvim", cs = "gruvbox", bg = "light" },
  { "Everforest", plugin = "everforest", cs = "everforest", bg = "dark" },
  { "One Dark", plugin = "onedarkpro.nvim", cs = "onedark" },
  { "Dracula", plugin = "dracula.nvim", cs = "dracula" },
}
M.default = "Catppuccin Mocha"

local file = vim.fn.stdpath("data") .. "/ide-theme.txt"

local function find(name)
  for _, t in ipairs(M.themes) do
    if t[1] == name then
      return t
    end
  end
end

function M.saved()
  local f = io.open(file, "r")
  if not f then
    return M.default
  end
  local name = f:read("*l")
  f:close()
  return find(name) and name or M.default
end

local function save(name)
  local f = io.open(file, "w")
  if f then
    f:write(name)
    f:close()
  end
end

M.current = nil

--- Load and activate a theme (no persistence).
function M.set(name)
  local t = find(name)
  if not t then
    return false
  end
  pcall(function()
    require("lazy").load({ plugins = { t.plugin } })
  end)
  if t.setup and t.plugin == "catppuccin" then
    local base = require("lazy.core.config").plugins.catppuccin
    require("catppuccin").setup(vim.tbl_deep_extend("force", base and base.opts or {}, t.setup))
  end
  vim.o.background = t.bg or "dark"
  local ok = pcall(vim.cmd.colorscheme, t.cs)
  if ok then
    M.current = name
    -- some themes (e.g. Dracula) paint their own bufferline groups after our ColorScheme handlers ran
    if package.loaded["bufferline.config"] then
      vim.schedule(function()
        pcall(function()
          require("bufferline.highlights").set_all(require("bufferline.config").update_highlights())
        end)
      end)
    end
  end
  return ok
end

function M.apply_saved()
  if not M.set(M.saved()) then
    M.set(M.default)
  end
end

-- ---------------------------------------------------------------------------------------------- palette
local function hl(name, key)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return ok and h and h[key] or nil
end

local function rgb(n)
  return math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256
end

--- Mix two 0xRRGGBB colours; t=0 -> a, t=1 -> b.
local function mix(a, b, t)
  local ar, ag, ab = rgb(a)
  local br, bg, bb = rgb(b)
  local function c(x, y)
    return math.floor(x + (y - x) * t + 0.5)
  end
  return c(ar, br) * 65536 + c(ag, bg) * 256 + c(ab, bb)
end

--- Colours taken from the active colorscheme (0xRRGGBB integers).
function M.palette()
  local light = vim.o.background == "light"
  local base = hl("Normal", "bg") or (light and 0xffffff or 0x1e1e1e)
  local text = hl("Normal", "fg") or (light and 0x222222 or 0xdddddd)
  local function accent(groups, fallback)
    for _, g in ipairs(groups) do
      local c = hl(g, "fg")
      if c then
        return c
      end
    end
    return fallback
  end
  local p = {
    base = base,
    text = text,
    mantle = mix(base, 0x000000, light and 0.05 or 0.22),
    crust = mix(base, 0x000000, light and 0.09 or 0.35),
    surface0 = mix(base, text, light and 0.10 or 0.12),
    surface1 = mix(base, text, 0.2),
    surface2 = mix(base, text, 0.3),
    overlay0 = accent({ "Comment" }, mix(base, text, 0.45)),
    blue = accent({ "Function", "@function" }, 0x89b4fa),
    mauve = accent({ "Keyword", "@keyword", "Statement" }, 0xcba6f7),
    peach = accent({ "Number", "Constant", "@number" }, 0xfab387),
    green = accent({ "String", "@string", "DiffAdd" }, 0xa6e3a1),
    red = accent({ "DiagnosticError", "Error" }, 0xf38ba8),
    yellow = accent({ "DiagnosticWarn", "WarningMsg" }, 0xf9e2af),
    teal = accent({ "Type", "@type" }, 0x94e2d5),
  }
  p.overlay1 = mix(p.overlay0, text, 0.25)
  return p
end

function M.hex(n)
  return string.format("#%06x", n)
end

function M.toggleterm_highlights()
  local c = M.palette()
  local panel = { guibg = M.hex(c.mantle) }
  return {
    Normal = panel,
    NormalFloat = panel,
    SignColumn = panel,
    EndOfBuffer = { guifg = M.hex(c.mantle), guibg = M.hex(c.mantle) },
    StatusLine = panel,
    StatusLineNC = panel,
    WinBar = panel,
    WinBarNC = panel,
    FloatBorder = { guifg = M.hex(c.blue), guibg = M.hex(c.mantle) },
  }
end

--- Highlight groups for the "IDE layer" UI, derived from the palette above.
function M.apply_ui()
  local c = M.palette()
  local set = function(name, val)
    vim.api.nvim_set_hl(0, name, val)
  end
  -- Floats are "outline cards": same background as the editor, separated by the rounded border only. One
  -- background for border and body means no dark rectangle around rounded corners and no light ring inside.
  for _, g in ipairs({ "FloatBorder", "BlinkCmpMenuBorder", "BlinkCmpDocBorder", "BlinkCmpSignatureHelpBorder" }) do
    set(g, { fg = c.blue, bg = c.base })
  end
  for _, g in ipairs({ "NormalFloat", "Pmenu", "BlinkCmpMenu", "BlinkCmpDoc", "BlinkCmpSignatureHelp" }) do
    set(g, { fg = c.text, bg = c.base })
  end
  set("FloatTitle", { fg = c.text, bg = c.base, bold = true })
  set("PmenuSbar", { bg = c.base })
  set("PmenuThumb", { bg = c.surface1 })
  -- dashboard: one accent (keys + wordmark), muted icons, plain labels, quiet footer
  set("SnacksDashboardHeader", { fg = c.blue, bold = true })
  set("SnacksDashboardIcon", { fg = c.overlay1 })
  set("SnacksDashboardDesc", { fg = c.text })
  set("SnacksDashboardKey", { fg = c.blue, bold = true })
  set("SnacksDashboardFooter", { fg = c.overlay0 })
  set("SnacksDashboardSpecial", { fg = c.overlay1 })
  -- quiet labels: sidebar title over the explorer, secondary statusline text, macro indicator
  set("IdeSidebarTitle", { fg = c.overlay1, bg = c.mantle, bold = true })
  set("IdeMuted", { fg = c.overlay1, bg = c.base })
  set("IdeRecording", { fg = c.red, bg = c.base, bold = true })
  set("WinSeparator", { fg = c.blue, bg = c.base })
  set("WhichKeyIcon", { fg = c.overlay1 })
  -- notifications: icon, title and border in the level colour, upright titles (several themes italicise them)
  for level, fg in pairs({ Info = c.blue, Warn = c.yellow, Error = c.red, Debug = c.overlay1, Trace = c.overlay0 }) do
    set("SnacksNotifierIcon" .. level, { fg = fg })
    set("SnacksNotifierTitle" .. level, { fg = fg, bold = true })
    set("SnacksNotifierBorder" .. level, { fg = fg, bg = c.base })
  end
  -- explorer panel: one shade darker than the editor
  set("NvimTreeNormal", { fg = c.text, bg = c.mantle })
  set("NvimTreeNormalNC", { fg = c.text, bg = c.mantle })
  set("NvimTreeEndOfBuffer", { fg = c.mantle, bg = c.mantle })
  set("NvimTreeWinSeparator", { fg = c.blue, bg = c.mantle })
  set("NvimTreeCursorLine", { bg = c.surface0 })
  set("NvimTreeRootFolder", { fg = c.mauve, bold = true })
  set("NvimTreeFolderName", { fg = c.text })
  set("NvimTreeOpenedFolderName", { fg = c.text, bold = true })
  set("NvimTreeEmptyFolderName", { fg = c.overlay1 })
  set("NvimTreeFolderIcon", { fg = c.blue })
  set("NvimTreeIndentMarker", { fg = c.surface1 })
  set("NvimTreeSpecialFile", { fg = c.peach })
  -- other uses of the symbol under the cursor (snacks.words): a soft bar, no underline
  for _, g in ipairs({ "LspReferenceText", "LspReferenceRead", "LspReferenceWrite", "SnacksWordsRef" }) do
    set(g, { bg = c.surface0 })
  end
  -- hairline indent guides: barely visible, the current scope a step brighter
  set("SnacksIndent", { fg = c.surface0 })
  set("SnacksIndentScope", { fg = c.surface2 })
  -- terminal panel: toggleterm keeps its own highlight table, rebuild it for the new colours
  if package.loaded["toggleterm.config"] then
    pcall(function()
      local cfg = require("toggleterm.config")
      cfg.get().highlights = M.toggleterm_highlights()
      cfg.reset_highlights()
    end)
  end
  -- terminal title: toggleterm re-creates these (blue, underlined) in its own ColorScheme handler, which runs
  -- after this one, so set them now and once more on the next tick
  local function winbar()
    set("WinBarActive", { fg = c.text, bg = c.mantle, bold = true })
    set("WinBarInactive", { fg = c.overlay0, bg = c.mantle })
  end
  winbar()
  vim.schedule(winbar)
end

--- Bufferline highlights ("island" tabs) from the palette.
function M.bufferline()
  local c = M.palette()
  local hls = {
    fill = { bg = c.base },
    background = { fg = c.overlay0, bg = c.base },
    tab = { fg = c.overlay0, bg = c.base },
    tab_selected = { fg = c.mauve, bg = c.surface0 },
    tab_separator = { fg = c.base, bg = c.base },
    tab_separator_selected = { fg = c.surface0, bg = c.base },
    tab_close = { fg = c.red, bg = c.base },
    close_button = { fg = c.overlay0, bg = c.base },
    close_button_visible = { fg = c.overlay0, bg = c.base },
    close_button_selected = { fg = c.red, bg = c.surface0 },
    buffer_visible = { fg = c.text, bg = c.base },
    buffer_selected = { fg = c.mauve, bg = c.surface0, bold = true, italic = false },
    numbers = { fg = c.overlay0, bg = c.base },
    numbers_visible = { fg = c.text, bg = c.base },
    numbers_selected = { fg = c.mauve, bg = c.surface0 },
    modified = { fg = c.yellow, bg = c.base },
    modified_visible = { fg = c.yellow, bg = c.base },
    modified_selected = { fg = c.yellow, bg = c.surface0 },
    duplicate = { fg = c.overlay0, bg = c.base },
    duplicate_visible = { fg = c.overlay0, bg = c.base },
    duplicate_selected = { fg = c.overlay1, bg = c.surface0 },
    indicator_visible = { fg = c.base, bg = c.base },
    indicator_selected = { fg = c.surface0, bg = c.surface0 },
    pick = { fg = c.red, bg = c.base, bold = true },
    pick_visible = { fg = c.red, bg = c.base, bold = true },
    pick_selected = { fg = c.red, bg = c.surface0, bold = true },
    separator = { fg = c.base, bg = c.base },
    separator_visible = { fg = c.base, bg = c.base },
    separator_selected = { fg = c.surface0, bg = c.base },
    offset_separator = { fg = c.base, bg = c.base },
  }
  for k, v in pairs(hls) do
    for _, key in ipairs({ "fg", "bg" }) do
      if type(v[key]) == "number" then
        v[key] = M.hex(v[key])
      end
    end
    hls[k] = v
  end
  return hls
end

-- ---------------------------------------------------------------------------------------------- picker
function M.pick()
  local fzf = require("fzf-lua")
  local shell = require("fzf-lua.shell")
  local before = M.current or M.saved()
  local names = {}
  for _, t in ipairs(M.themes) do
    names[#names + 1] = t[1]
  end
  -- current theme first
  for i, n in ipairs(names) do
    if n == before then
      table.remove(names, i)
      table.insert(names, 1, n)
      break
    end
  end
  local chosen = false
  local opts = {
    prompt = "Theme> ",
    winopts = {
      height = 0.45,
      width = 0.3,
      row = 0.15,
      col = 0.5,
      on_close = function()
        if not chosen then
          M.set(before)
        end
      end,
    },
    fzf_opts = { ["--preview-window"] = "nohidden:right:0", ["--no-multi"] = true },
    actions = {
      ["default"] = function(sel)
        if sel and sel[1] then
          chosen = true
          M.set(sel[1])
          save(sel[1])
          vim.notify("Theme: " .. sel[1], vim.log.levels.INFO, { title = "Colorscheme" })
        end
      end,
    },
  }
  -- live preview: each time the highlighted entry changes, apply that theme
  opts.preview = shell.stringify_data(function(sel)
    if sel and sel[1] then
      M.set(sel[1])
    end
    return ""
  end, opts, "{}")
  fzf.fzf_exec(names, opts)
end

return M
