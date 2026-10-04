-- lualine theme built from the active colorscheme (lualine re-reads it on every ColorScheme event)
local T = require("util.theme")
local c = T.palette()
local h = T.hex

local function mode(color)
  return {
    a = { fg = h(c.base), bg = h(color), gui = "bold" },
    b = { fg = h(c.text), bg = h(c.surface0) },
    c = { fg = h(c.text), bg = h(c.base) },
  }
end

return {
  normal = mode(c.blue),
  insert = mode(c.green),
  visual = mode(c.mauve),
  replace = mode(c.red),
  command = mode(c.peach),
  terminal = mode(c.teal),
  inactive = {
    a = { fg = h(c.overlay0), bg = h(c.base) },
    b = { fg = h(c.overlay0), bg = h(c.base) },
    c = { fg = h(c.overlay0), bg = h(c.base) },
  },
}
