-- Fuzzy finder: fzf-lua (uses the fzf / rg / fd already on PATH)
local function pick(cmd, o)
  return function()
    local opts = vim.deepcopy(o or {})
    opts.cwd = opts.cwd or require("util").root()
    require("fzf-lua")[cmd](opts)
  end
end

return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    init = function()
      -- lazy vim.ui.select: load fzf-lua on first use and let it take over
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "fzf-lua" } })
        require("fzf-lua").register_ui_select()
        return vim.ui.select(...)
      end
    end,
    opts = {
      "default-title",
      fzf_colors = true,
      fzf_opts = { ["--no-scrollbar"] = true },
      defaults = { formatter = "path.filename_first" },
      winopts = {
        width = 0.85,
        height = 0.85,
        row = 0.5,
        col = 0.5,
        preview = { scrollchars = { "┃", "" } },
      },
      files = { cwd_prompt = false },
      grep = { rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e" },
      oldfiles = { include_current_session = true },
      previewers = { builtin = { syntax_limit_b = 1024 * 100 } },
    },
    keys = {
      { "<leader>,", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch Buffer" },
      { "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      { "<leader><space>", pick("files"), desc = "Find Files (Root Dir)" },
      -- find
      { "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>fc", pick("files", { cwd = vim.fn.stdpath("config") }), desc = "Find Config File" },
      { "<leader>ff", pick("files"), desc = "Find Files (Root Dir)" },
      { "<leader>fF", pick("files", { cwd = vim.uv.cwd() }), desc = "Find Files (cwd)" },
      { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Find Files (git-files)" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
      { "<leader>fR", pick("oldfiles", { cwd = vim.uv.cwd(), cwd_only = true }), desc = "Recent (cwd)" },
      -- git
      { "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Git Commits" },
      { "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Git Status" },
      { "<leader>gS", "<cmd>FzfLua git_stash<cr>", desc = "Git Stash" },
      -- search
      { '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
      { "<leader>sa", "<cmd>FzfLua autocmds<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>", desc = "Buffer Lines" },
      { "<leader>sc", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document Diagnostics" },
      { "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics" },
      { "<leader>sg", pick("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>sG", pick("live_grep", { cwd = vim.uv.cwd() }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>FzfLua highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sj", "<cmd>FzfLua jumps<cr>", desc = "Jumplist" },
      { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Key Maps" },
      { "<leader>sl", "<cmd>FzfLua loclist<cr>", desc = "Location List" },
      { "<leader>sM", "<cmd>FzfLua manpages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "Jump to Mark" },
      { "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume" },
      { "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
      { "<leader>sw", pick("grep_cword"), desc = "Word (Root Dir)" },
      { "<leader>sW", pick("grep_cword", { cwd = vim.uv.cwd() }), desc = "Word (cwd)" },
      { "<leader>sw", pick("grep_visual"), mode = "x", desc = "Selection (Root Dir)" },
      { "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Goto Symbol" },
      { "<leader>sS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Goto Symbol (Workspace)" },
      { "<leader>uC", function() require("util.theme").pick() end, desc = "Colorscheme with Preview" },
    },
  },
}
