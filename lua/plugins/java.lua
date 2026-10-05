-- Java: nvim-jdtls (full jdtls with debug + tests). Servers/jars come from Mason (see plugins/lsp.lua).
-- jdtls needs JDK 21+ to run; your projects can target any installed JDK.

local markers = {
  "mvnw",
  "gradlew",
  "pom.xml",
  "build.gradle",
  "build.gradle.kts",
  "settings.gradle",
  "settings.gradle.kts",
  "build.xml",
  ".project",
  ".git",
}

---Project root. A loose .java file (no build file / .git above it) gets a root derived from its `package` line:
---`package a.b.c;` in <dir>/a/b/c/X.java means <dir> is the source root. Without that, jdtls assumes the file's
---own folder is the source root, reports 'declared package "a.b.c" does not match the expected package ""',
---and resolves types (and `this.` completion) unreliably. No package line: the file's own folder.
---@param file string
local function root_dir(file)
  local root = vim.fs.root(file, markers)
  if root then
    return root
  end
  local dir = vim.fs.dirname(file)
  local ok, lines = pcall(vim.fn.readfile, file, "", 60)
  for _, line in ipairs(ok and lines or {}) do
    local pkg = line:match("^%s*package%s+([%w_.]+)%s*;")
    if pkg then
      local up = dir
      for part in vim.iter(vim.split(pkg, ".", { plain = true })):rev() do
        if vim.fs.basename(up) ~= part then
          return dir -- folders do not follow the package: keep the old behaviour
        end
        up = vim.fs.dirname(up)
      end
      return up
    end
  end
  return dir
end

---@param root string
local function project_name(root)
  return vim.fs.basename(root) .. "-" .. vim.fn.sha256(root):sub(1, 8)
end

return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = { "neovim/nvim-lspconfig", "folke/which-key.nvim", "mfussenegger/nvim-dap" },
    config = function()
      local mason = vim.fn.stdpath("data") .. "/mason"

      -- debug + test bundles (installed through Mason)
      local bundles =
        vim.fn.glob(mason .. "/share/java-debug-adapter/com.microsoft.java.debug.plugin-*.jar", false, true)
      -- Not every jar Mason links there is a loadable bundle: the test runner fat jar and the jacoco agent are not
      -- OSGi bundles, com.microsoft.java.test.plugin.jar duplicates the versioned plugin-*.jar, and asm / jacoco
      -- (coverage only) clash with jdtls's own copies. Loading them makes jdtls fail at startup with
      -- "Cannot refresh bundle org.eclipse.jdt.ls.core" and run without the debug / test extensions.
      local skip = {
        ["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
        ["jacocoagent.jar"] = true,
        ["com.microsoft.java.test.plugin.jar"] = true,
      }
      for _, jar in ipairs(vim.fn.glob(mason .. "/share/java-test/*.jar", false, true)) do
        local base = vim.fs.basename(jar)
        if not skip[base] and not base:find("^org%.objectweb") and not base:find("^org%.jacoco") then
          bundles[#bundles + 1] = jar
        end
      end

      local function attach()
        local file = vim.api.nvim_buf_get_name(0)
        if file == "" then
          return
        end
        local root = root_dir(file)
        local name = project_name(root)
        local cache = vim.fn.stdpath("cache") .. "/jdtls/" .. name

        local cmd = { vim.fn.exepath("jdtls") }
        local lombok = mason .. "/share/jdtls/lombok.jar"
        if vim.uv.fs_stat(lombok) then
          table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok)
        end
        vim.list_extend(cmd, { "-configuration", cache .. "/config", "-data", cache .. "/workspace" })

        require("jdtls").start_or_attach({
          cmd = cmd,
          root_dir = root,
          init_options = { bundles = bundles },
          capabilities = require("util").lsp_capabilities(),
          settings = {
            java = {
              inlayHints = { parameterNames = { enabled = "all" } },
              -- loose files (no build file): the whole root folder is the source root (see root_dir)
              project = { sourcePaths = { "." } },
            },
          },
        })
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ide_jdtls", { clear = true }),
        pattern = "java",
        callback = attach,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("ide_jdtls_attach", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "jdtls" then
            return
          end
          local jdtls = require("jdtls")
          local wk = require("which-key")
          wk.add({
            {
              mode = "n",
              buffer = args.buf,
              { "<leader>cx", group = "extract" },
              { "<leader>cxv", jdtls.extract_variable_all, desc = "Extract Variable" },
              { "<leader>cxc", jdtls.extract_constant, desc = "Extract Constant" },
              { "<leader>cgs", jdtls.super_implementation, desc = "Goto Super" },
              { "<leader>cgS", require("jdtls.tests").goto_subjects, desc = "Goto Subjects" },
              { "<leader>co", jdtls.organize_imports, desc = "Organize Imports" },
            },
            {
              mode = "x",
              buffer = args.buf,
              { "<leader>cx", group = "extract" },
              { "<leader>cxm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], desc = "Extract Method" },
              {
                "<leader>cxv",
                [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
                desc = "Extract Variable",
              },
              {
                "<leader>cxc",
                [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
                desc = "Extract Constant",
              },
            },
          })

          -- debugger + tests need the Mason bundles
          if #bundles > 0 then
            jdtls.setup_dap({ hotcodereplace = "auto" })
            require("jdtls.dap").setup_dap_main_class_configs()
            wk.add({
              mode = "n",
              buffer = args.buf,
              { "<leader>dT", group = "java test" },
              { "<leader>dTt", require("jdtls.dap").test_class, desc = "Run All Tests (Class)" },
              { "<leader>dTr", require("jdtls.dap").test_nearest_method, desc = "Run Nearest Test" },
              { "<leader>dTT", require("jdtls.dap").pick_test, desc = "Pick Test" },
            })
          end
        end,
      })

      -- this plugin loads on FileType=java, so the first buffer needs a direct call
      attach()
    end,
  },
}
