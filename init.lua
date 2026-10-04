-- Byte-compile + cache every Lua module (biggest single win for Windows startup)
vim.loader.enable()

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
