-- neovim — ported from eeepy home.nix (Synthwave84)
vim.g.mapleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.termguicolors = true
o.cursorline = true
o.signcolumn = "yes"
o.scrolloff = 6
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.undofile = true
o.wrap = false
o.splitright = true
o.splitbelow = true
o.mouse = "a"
o.clipboard = "unnamedplus"

-- ── bootstrap lazy.nvim ─────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "nix", "lua", "bash", "python", "markdown", "markdown_inline",
          "json", "yaml", "toml", "c", "rust", "javascript", "typescript",
          "tsx", "html", "css", "kdl", "vim", "vimdoc", "regex", "diff",
        },
        highlight = { enable = true },
      })
    end,
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          globalstatus = true,
          section_separators = "",
          component_separators = "|",
        },
      })
    end,
  },
  { "lewis6991/gitsigns.nvim", config = true },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = { scope = { enabled = false } },
  },
  {
    "LunarVim/synthwave84.nvim",
    commit = "eac1f349713e2f470d8ee857913a42135bcc1a7f",
    priority = 1000,
    config = function()
      require("synthwave84").setup({
        glow = {
          error_msg = true,
          type = true,
          string = true,
          function_names = true,
          keyword = true,
          operator = false,
        },
      })
      vim.cmd.colorscheme("synthwave84")
    end,
  },
}, {
  install = { colorscheme = { "synthwave84", "habamax" } },
  change_detection = { notify = false },
})
