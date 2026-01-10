-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP
  {
    "neovim/nvim-lspconfig",
  },

  -- Autocompletion (optional but recommended)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
  },

  -- File search (VS Code-like)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Gruvbox theme
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
  },
 {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    -- nothing here, we’ll start manually
  end,
},
{
  "sphamba/smear-cursor.nvim",
  opts = {
    smear_between_buffers = true,
    smear_between_neighbor_lines = true,
    smear_insert_mode = true,
  },
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",  -- load on buffer read
    config = function()
      require("illuminate").configure({
        delay = 100,           -- ms before highlighting
        under_cursor = true,   -- highlight the word under the cursor differently
        filetypes_denylist = { "nerdtree", "lazy", "dashboard" }, -- optional
      })
      vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#f3f3f3", ctermbg = 252, fg = nil })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#f3f3f3", ctermbg = 252, fg = nil })
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#f3f3f3", ctermbg = 252, fg = nil })
    end,
  },
}

})

require("nvim-treesitter.install").prefer_git = true

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  callback = function(args)
    if vim.treesitter.highlighter.active[args.buf] == nil then
      local ok, _ = pcall(vim.treesitter.start, args.buf)
      if not ok then
        vim.notify("Tree-sitter parser could not be started for buffer " .. args.buf)
      end
    end
  end,
})


require("gruvbox").setup({
  contrast = "hard",
  italic = { strings = true, comments = true, operators = false, folds = true },
  overrides = {
    ["@function"]        = { fg = "#fabd2f" },
    ["@method"]          = { fg = "#fabd2f" },
    ["@keyword"]         = { fg = "#fb4934", bold = true },
    ["@type"]            = { fg = "#8ec07c" },
    ["@class"]           = { fg = "#8ec07c", bold = true },
    ["@string"]          = { fg = "#b8bb26" },
    ["@number"]          = { fg = "#d3869b" },
    ["@comment"]         = { fg = "#928374", italic = true },

    -- Python-specific
    ["@function.python"] = { fg = "#fabd2f" },
    ["@method.python"]   = { fg = "#fabd2f" },
    ["@class.python"]    = { fg = "#8ec07c", bold = true },
    ["@keyword.python"]  = { fg = "#fb4934", bold = true },
    ["@parameter.python"]= { fg = "#83a598" },
    ["@property.python"] = { fg = "#d3869b" },
  },
})
vim.cmd.colorscheme("gruvbox")



vim.o.termguicolors = true
vim.cmd("colorscheme gruvbox")

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
  },
  on_attach = on_attach,
})

vim.lsp.enable("clangd")

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gb", "<C-o>", { desc = "Go back" })

local function on_attach(_, bufnr)
  local opts = { buffer = bufnr }

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gb", "<C-o>", opts)
end

-- Python
vim.lsp.config("pyright", {
  on_attach = on_attach,
})

vim.lsp.enable("pyright")

vim.g.mapleader = " "
local telescope = require("telescope.builtin")

vim.keymap.set("n", "ff", telescope.find_files, { desc = "Find files" })
vim.keymap.set("n", "fg", telescope.live_grep, { desc = "Search text" })
vim.keymap.set("n", "fb", telescope.buffers, { desc = "Buffers" })
vim.keymap.set("n", "fh", telescope.help_tags, { desc = "Help" })

vim.api.nvim_set_keymap('n', 'rn', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })

-- Press <leader>r to replace word under cursor in the whole file
vim.api.nvim_set_keymap('n', 'r', ':%s/\\<<C-r><C-w>\\>/newword/gc<Left><Left><Left>', { noremap = true, silent = false })

vim.keymap.set(
  "n",
  "fs",
  function()
    require("telescope.builtin").lsp_document_symbols({
      initial_mode = "normal",
    })
  end,
  { desc = "Find symbols in file (@)" }
)

local cmp = require("cmp")

cmp.setup({
  completion = {
    completeopt = "menu,menuone,noselect",
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = {
    { name = "nvim_lsp" },
  },
})

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.cmd [[
  autocmd CursorHold * lua vim.diagnostic.open_float(nil, {scope="cursor", focus=false})
]]
vim.o.updatetime = 100  -- 100ms delay, almost instant

