# nvim-ide-layer

A Windows-first Neovim "IDE layer" in the spirit of LazyVim / NvChad: 20 switchable themes with live preview
(`<leader>uC`) and a UI that recolours itself to match, island tabs, framed side panels, Claude Code inside Neovim.

## Install (Windows, PowerShell)

```powershell
irm https://raw.githubusercontent.com/Punssama/nvim-ide-layer/main/install.ps1 | iex
```

Your current `%LOCALAPPDATA%
vim` is moved to `nvim.bak-<timestamp>`, the config is cloned, and missing tools are listed.
Then run `nvim`; plugins install on first start. Manual: `git clone https://github.com/Punssama/nvim-ide-layer $env:LOCALAPPDATA
vim`.


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
  colorscheme.lua         catppuccin + 8 lazy theme plugins; theme manager is lua/util/theme.lua (picker <leader>uC, choice saved in nvim-data/ide-theme.txt, UI colours derived from the active theme)
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
  ai.lua                  claudecode.nvim: Claude Code in a side terminal (<leader>a*), IDE protocol like VS Code
```

## Your keymaps (kept 1:1)

`+`/`-` inc/dec, `zz` redo, `dw` delete word back, `<C-a>` select all, `te`/`tr` tab/buffer,
`sd`/`sn` split, `sh sj sk sl` / `ww` window nav, `<C-w><arrows>` resize, `<C-j>`/`<C-k>` diagnostics,
`<space>w` save, `<space>e` / `<space>fe` explorer, `<space>t` terminal, `<space>to` external Alacritty,
`<S-h>`/`<S-l>` buffers, `<C-\>` toggleterm.

`<leader>/` toggles comments (line, count, or visual selection); grep is `<leader>sg`. Claude Code: `<leader>ac` toggle, `af` focus, `as` send selection / add file in tree, `ab` add buffer, `aa`/`ad` accept/deny diff.

Explorer and terminal root: the folder you started Neovim in (or `:cd`) wins whenever the file is inside it; only files outside it fall back to the LSP/git root.

`<leader>e` is a 3-state toggle: closed -> open + focus; open but cursor in the editor -> focus the explorer
(revealing the current file); cursor already in the explorer -> close. `<leader>ug` turns the explorer's git marks
on/off (off by default: with it on, nvim-tree spawns `git rev-parse` per folder, ~70ms each on Windows).
nvim-tree's file watchers skip churn-heavy folders (`.git`, `node_modules`, `.venv`, `build`, nvim-data, ...) and never raise the
Windows-only "Observed 1001 consecutive file system events" error (`max_events = 0`); press `R` in the tree to refresh by hand.
The tree is titled EXPLORER, shows the project name as its root, and hides `.git`, `__pycache__`, `node_modules` and `.cache`
(`U` in the tree shows them).
Completion menu: `<C-j>` / `<C-k>` select next / previous; snippets are left out right after `.` / `->`, where only members make sense.

UX extras: `Esc` also closes hover / signature popups;
right click opens a context menu (definition, references, rename, code action, format, comment, copy/paste);
`<leader>uz` zen mode, `<leader>uZ` maximize / restore the current split (needs 2+ editor windows), `<leader>un` dismiss notifications, `<leader>sN` notification history,
`]r` / `[r` jump between references of the symbol under the cursor (they are softly highlighted), treesitter folds
(`za`/`zc`/`zM`/`zR`, all open by default), search count and macro-recording indicator in the statusline,
window title `file - project`.

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
