# Neovim IDE layer

Minimal, fast, Windows-first Neovim config. Catppuccin Mocha, JetBrainsMono Nerd Font, LazyVim-like UI,
LunarVim's file explorer (nvim-tree) and terminal (toggleterm), Java + Python out of the box.

Requires Neovim 0.12+, git, a C compiler (gcc), `tree-sitter` CLI, `rg`, `fd`, `fzf`, JDK 21+ (for jdtls).

## Layout

```
init.lua                  vim.loader + options -> lazy -> keymaps -> autocmds
lua/config/options.lua    options, provider/clipboard/shell tweaks
lua/config/lazy.lua       lazy.nvim bootstrap (everything lazy by default, no update checker)
lua/config/keymaps.lua    your keymaps + LazyVim-style leader map (non-plugin keys)
lua/config/autocmds.lua
lua/util/init.lua         icons, project root, static LSP capabilities, Mason ensure_installed
lua/plugins/
  colorscheme.lua         catppuccin mocha
  ui.lua                  snacks (dashboard/indent/notifier), bufferline, lualine, noice, which-key, persistence
  explorer.lua            nvim-tree  (LunarVim config)
  terminal.lua            toggleterm (LunarVim config, Nushell)
  picker.lua              fzf-lua
  editor.lua              gitsigns, trouble, todo-comments, mini.pairs/surround/ai, ts-comments, lazydev
  treesitter.lua          nvim-treesitter (main) + textobjects; parsers auto-install on first open
  lsp.lua                 mason + native vim.lsp.config; add a language with :Mason
  completion.lua          blink.cmp
  formatting.lua          conform (format on save, toggle <leader>uf)
  dap.lua / java.lua      nvim-dap(+ui), debugpy, nvim-jdtls (debug + tests)
```

## Your keymaps (kept 1:1)

`+`/`-` inc/dec, `zz` redo, `dw` delete word back, `<C-a>` select all, `te`/`tr` tab/buffer,
`sd`/`sn` split, `sh sj sk sl` / `ww` window nav, `<C-w><arrows>` resize, `<C-j>`/`<C-k>` diagnostics,
`<space>w` save, `<space>e` / `<space>fe` explorer, `<space>t` terminal, `<space>to` external Alacritty,
`<S-h>`/`<S-l>` buffers, `<C-\>` toggleterm.

Known collisions with Vim built-ins (kept on purpose): `zz` (centre cursor), `dw` (delete word forward),
`te`/`tr` (till `e`/`r`), `s` (substitute), `-` (up a line). `<space>t` waits `timeoutlen` because `<space>to` exists.

## LazyVim leader map

`<leader><space>` files, `/` grep, `,` buffers, `:` cmd history, `f*` files, `s*` search, `g*` git (`gh*` hunks),
`c*` code (`ca` action, `cr` rename, `cf` format, `cd` diagnostic), `x*` trouble, `d*` debug, `b*` buffers,
`u*` toggles, `q*` session, `<tab>*` tabs, `l` Lazy, `cm` Mason. `<leader>w` is yours (save), so LazyVim's `<leader>w*` window group is not defined.
Java: `<leader>co` organize imports, `<leader>cx*` extract, `<leader>dT*` run tests.

## Switching back to LazyVim

The old setup is untouched in `%LOCALAPPDATA%\nvim-lazyvim` (data in `nvim-lazyvim-data`):

```powershell
$env:NVIM_APPNAME = 'nvim-lazyvim'; nvim      # or just run: nvl
```

## Performance notes (Windows)

- `vim.loader`, everything lazy, no update checker, unused providers off, clipboard set after first frame.
- LSP servers are started after the first frame; blink.cmp loads on first insert; gitsigns after first frame.
- Avoid `vim.fn.executable()` at startup: ~5ms per call on this PATH (63 entries).
- Outside the config: `LANG=C` skips a ~21ms locale lookup, and calling `nvim.exe` directly instead of the scoop shim saves ~40ms.
