---@class util
local M = {}

M.icons = {
  diagnostics = { Error = "\u{f057} ", Warn = "\u{f071} ", Hint = "\u{f0eb} ", Info = "\u{f05a} " },
  git = { added = "\u{f457} ", modified = "\u{f459} ", removed = "\u{f458} " },
}

-- Project markers, nearest match wins. Sub-project markers come before the parent .git
-- so a nested project is detected as its own root (same intent as the old LazyVim root_spec).
local root_names = {
  ["pom.xml"] = true,
  ["build.gradle"] = true,
  ["build.gradle.kts"] = true,
  ["settings.gradle"] = true,
  ["settings.gradle.kts"] = true,
  [".project"] = true,
  ["package.json"] = true,
  ["tsconfig.json"] = true,
  ["Cargo.toml"] = true,
  ["go.mod"] = true,
  ["pyproject.toml"] = true,
  ["requirements.txt"] = true,
  ["CMakeLists.txt"] = true,
  ["Makefile"] = true,
  ["pubspec.yaml"] = true,
  ["composer.json"] = true,
  [".idea"] = true,
  [".vscode"] = true,
  [".git"] = true,
}
local root_patterns = { "%.code%-workspace$", "%.sln$", "%.slnx$", "%.csproj$" }

local function is_root_marker(name)
  if root_names[name] then
    return true
  end
  for _, pat in ipairs(root_patterns) do
    if name:find(pat) then
      return true
    end
  end
  return false
end

---Project root for a buffer: LSP workspace first, then project markers, then cwd.
---@param buf? integer
---@return string
function M.root(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local name = vim.api.nvim_buf_get_name(buf)
  local dir = name ~= "" and vim.fs.dirname(vim.fs.normalize(name)) or nil

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    local root = client.root_dir
    if root and root ~= "" and client.name ~= "copilot" then
      return vim.fs.normalize(root)
    end
  end

  if dir and vim.fn.isdirectory(dir) == 1 then
    local found = vim.fs.root(dir, function(n)
      return is_root_marker(n)
    end)
    if found then
      return vim.fs.normalize(found)
    end
  end
  return vim.fs.normalize(vim.uv.cwd() or ".")
end

---Directory of the current file's project, else cwd. Used by the explorer / terminal keymaps.
---@return string
function M.current_dir()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype == "" and name ~= "" and vim.fn.filereadable(name) == 1 then
    local root = M.root(buf)
    if vim.fn.isdirectory(root) == 1 then
      return root
    end
    local dir = vim.fs.dirname(vim.fs.normalize(name))
    if dir and vim.fn.isdirectory(dir) == 1 then
      return dir
    end
  end
  return vim.fs.normalize(vim.uv.cwd() or ".")
end

---LSP client capabilities, identical to require("blink.cmp").get_lsp_capabilities({...}, true)
---but without loading blink.cmp (~38ms) when a file is opened; blink then loads on first insert.
---Keep in sync with blink.cmp.sources.lib.get_lsp_capabilities.
---@return table
function M.lsp_capabilities()
  return vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
    workspace = { fileOperations = { didRename = true, willRename = true } },
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          commitCharactersSupport = false,
          documentationFormat = { "markdown", "plaintext" },
          deprecatedSupport = true,
          preselectSupport = false,
          tagSupport = { valueSet = { 1 } },
          insertReplaceSupport = true,
          resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits", "command", "data" } },
          insertTextModeSupport = { valueSet = { 1 } },
          labelDetailsSupport = true,
        },
        completionList = {
          itemDefaults = { "commitCharacters", "editRange", "insertTextFormat", "insertTextMode", "data" },
        },
        contextSupport = true,
        insertTextMode = 1,
      },
    },
  })
end

---Run `fn` once when a lazy.nvim plugin has been loaded (or right away if it already is).
---@param name string
---@param fn fun(name: string)
function M.on_load(name, fn)
  local Config = require("lazy.core.config")
  if Config.plugins[name] and Config.plugins[name]._.loaded then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(ev)
        if ev.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

---Install Mason packages once. A marker file keyed by the package list means later startups
---never touch the (slow to parse) Mason registry.
---@param packages string[]
function M.mason_ensure(packages)
  table.sort(packages)
  local key = table.concat(packages, ",")
  local marker = vim.fn.stdpath("state") .. "/mason-ensured"
  local f = io.open(marker, "r")
  if f then
    local saved = f:read("*a")
    f:close()
    if saved == key then
      return
    end
  end

  local registry = require("mason-registry")
  registry.refresh(function()
    local pending = 0
    local failed = false
    local function done()
      pending = pending - 1
      if pending == 0 and not failed then
        local out = io.open(marker, "w")
        if out then
          out:write(key)
          out:close()
        end
      end
    end
    for _, name in ipairs(packages) do
      local ok, pkg = pcall(registry.get_package, name)
      if ok and not pkg:is_installed() then
        pending = pending + 1
        pkg:install({}, function(success)
          failed = failed or not success
          vim.schedule(done)
        end)
      elseif not ok then
        failed = true
        vim.notify("Mason: unknown package '" .. name .. "'", vim.log.levels.WARN)
      end
    end
    if pending == 0 and not failed then
      local out = io.open(marker, "w")
      if out then
        out:write(key)
        out:close()
      end
    end
  end)
end

return M
