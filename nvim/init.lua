-- ~/.config/nvim/init.lua

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.g.mapleader = " "

-- Lazy.nvim path
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

-- Safe load Lazy.nvim
local ok, lazy = pcall(require, "lazy")

vim.opt.clipboard = "unnamedplus"

lazy.setup({
    {
  "williamboman/mason.nvim",
  config = function()
    require("mason").setup()
  end,
},
{
  "williamboman/mason-lspconfig.nvim",
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "pyright",
        "clangd",
        "ts_ls",
        "cssls",
        "html",
        "jdtls",
      },
    })
  end,
},
{
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup()
    vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>")
  end,
},
{
  "windwp/nvim-ts-autotag",
  event = "InsertEnter",
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = function()
    require("nvim-ts-autotag").setup()
  end,
},
{
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    require("nvim-autopairs").setup({
      check_ts = true, -- use treesitter
    })
  end,
},
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = { light = "latte", dark = "mocha" },
        transparent_background = false,
        term_colors = true,
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Open buffers" })
    vim.keymap.set("n", "<leader><Tab>", ":bnext<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<Space><S-Tab>", ":bprevious<CR>", { noremap = true, silent = true })
  end,
},
{
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  config = function()
    require("telescope").load_extension("file_browser")
    -- Ctrl+p for GUI-like file search
    vim.keymap.set("n", "<C-p>", function()
      require("telescope").extensions.file_browser.file_browser({
        cwd = vim.loop.cwd(),
        respect_gitignore = false,
        hidden = true,
        grouped = true,
        previewer = true,
        layout_config = { width = 0.9, height = 0.6 },
      })
    end, { desc = "Browse files" })
  end,
},
{
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ok, ts = pcall(require, "nvim-treesitter.configs")
    if not ok then
      return
    end
    ts.setup({
        ensure_installed = {
  "c",
  "cpp",
  "lua",
  "python",
  "javascript",
  "typescript",
  "tsx",
  "html",
  "css",
  "markdown",
  "java",
},

        highlight = { enable = true },
      indent = { enable = true },
      autotag = {
          enable = true,
      },
    })
  end,
},
{
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local cmp = require("cmp")
    require("luasnip.loaders.from_vscode").lazy_load()
    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
  ["<Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.confirm({ select = true })
    else
      fallback()
    end
  end, { "i", "s" }),

  ["<S-Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
    else
      fallback()
    end
  end, { "i", "s" }),

  ["<CR>"] = cmp.mapping.confirm({ select = true }),
}),

      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end,
},
{
  "neovim/nvim-lspconfig",
  config = function()
    local ok, lspconfig = pcall(require, "lspconfig")
    if not ok then
      return
    end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.pyright.setup({
  capabilities = capabilities,
})

lspconfig.clangd.setup({
  capabilities = capabilities,
})

lspconfig.ts_ls.setup({
  capabilities = capabilities,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  settings = {
    typescript = {
      preferences = {
        importModuleSpecifierPreference = "relative",
        importModuleSpecifierEnding = "minimal",
      },
    },
    javascript = {
      preferences = {
        importModuleSpecifierPreference = "relative",
        importModuleSpecifierEnding = "minimal",
      },
    },
  },
})
-- CSS
lspconfig.cssls.setup({
  capabilities = capabilities,
})

-- HTML
lspconfig.html.setup({
  capabilities = capabilities,
})

-- JAVA (JDTLS)
local mason_path = vim.fn.stdpath("data") .. "/mason/"
local jdtls_path = mason_path .. "packages/jdtls"
local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
local config = jdtls_path .. "/config_linux"

local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")


    vim.keymap.set("n", "gd", vim.lsp.buf.definition)
    vim.keymap.set("n", "K", vim.lsp.buf.hover)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
  end,
},

})

vim.keymap.set('v', '<leader>y', '"+y', { desc = "Copy selection to system clipboard" })
vim.keymap.set('n', '<leader>y', '"+yy', { desc = "Copy line to system clipboard" })
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })
vim.filetype.add({
  extension = {
    jsx = "javascriptreact",
    tsx = "typescriptreact",
  },
})

-- Show diagnostics in a floating window when cursor stays on line
vim.o.updatetime = 250

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "rounded",
      source = "always",
      prefix = " ",
      scope = "cursor",
    })
  end,
})

-- ================= JAVA LSP (JDTLS) =================
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local home = os.getenv("HOME")
    local mason_path = vim.fn.stdpath("data") .. "/mason/"
    local jdtls_path = mason_path .. "packages/jdtls"
    local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
    local config = jdtls_path .. "/config_linux"

    local workspace_dir = home .. "/.local/share/jdtls-workspace/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

    local cmd = {
      "java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xmx1g",
      "--add-modules=ALL-SYSTEM",
      "--add-opens", "java.base/java.util=ALL-UNNAMED",
      "--add-opens", "java.base/java.lang=ALL-UNNAMED",
      "-jar", launcher_jar,
      "-configuration", config,
      "-data", workspace_dir,
    }

    vim.lsp.start({
      name = "jdtls",
      cmd = cmd,
      root_dir = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", "build.gradle", ".git" }) or vim.fn.getcwd(),
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })
  end,
})
