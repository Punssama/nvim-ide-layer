# Installs this Neovim config to %LOCALAPPDATA%\nvim (an existing config is moved to nvim.bak-<timestamp>, never deleted).
#   irm https://raw.githubusercontent.com/Punssama/nvim-ide-layer/main/install.ps1 | iex
$ErrorActionPreference = "Stop"
$repo = "https://github.com/Punssama/nvim-ide-layer.git"
$dest = Join-Path $env:LOCALAPPDATA "nvim"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "git is required: scoop install git" }

if (Test-Path $dest) {
  $backup = "$dest.bak-" + (Get-Date -Format "yyyyMMdd-HHmmss")
  Move-Item $dest $backup
  Write-Host "Existing config moved to $backup"
}
git clone --depth 1 $repo $dest

$need = @{
  nvim = "neovim (0.12+)"; rg = "ripgrep"; fd = "fd"; fzf = "fzf"; gcc = "gcc (or mingw)"; "tree-sitter" = "tree-sitter-cli"; java = "openjdk (21+, for jdtls)"
}
$missing = $need.Keys | Where-Object { -not (Get-Command $_ -ErrorAction SilentlyContinue) }
if ($missing) {
  Write-Host "`nMissing tools: $($missing -join ', ')"
  Write-Host "With scoop:  scoop install neovim ripgrep fd fzf gcc tree-sitter openjdk"
}
Write-Host "`nDone. Run 'nvim' - plugins install on first start. Font: JetBrainsMono Nerd Font (scoop bucket nerd-fonts)."
