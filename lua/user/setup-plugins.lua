-- auto install packer if not installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer() -- true if packer was just installed

-- autocommand that reloads neovim and installs/updates/removes plugins
-- when file is saved
vim.cmd([[ 
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost setup-plugins.lua source <afile> | PackerSync
  augroup end
]])


-- import packer safely
local status, packer = pcall(require, "packer")
if not status then
  return
end

-- add list of plugins to install
return packer.startup(function(use)
  -- packer can manage itself
  use("wbthomason/packer.nvim")
  use("nvim-lua/plenary.nvim") -- lua functions that many plugins use
  use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install",
    setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })
  use("phanviet/vim-monokai-pro") -- preferred colorscheme
  use 'terryma/vim-multiple-cursors'
  --jjuse("christoomey/vim-tmux-navigator") -- tmux & split window navigation

  use 'jwalton512/vim-blade'
  -- use "simrat39/symbols-outline.nvim"
  -- use("szw/vim-maximizer") -- maximizes and restores current window
  --
  use "github/copilot.vim"

  -- use {
  --   "zbirenbaum/copilot.lua",
  --   event = { "VimEnter" },
  --   config = function()
  --     vim.defer_fn(function()
  --       require "user.copilot"
  --     end, 100)
  --   end,
  -- }
  --
  -- use "zbirenbaum/copilot-cmp"
  use("justinmk/vim-sneak")
  use 'mattn/emmet-vim'
  use('jose-elias-alvarez/null-ls.nvim')
  use('MunifTanjim/prettier.nvim')
  -- essential plugins
  use("tpope/vim-surround") -- add, delete, change surroundings (it's awesome)
  -- use("vim-scripts/ReplaceWithRegister") -- replace with register contents using motion (gr + motion)
  -- use('neoclide/coc.nvim')
  -- commenting with gc
  use("numToStr/Comment.nvim")

  -- file explorer
  use("nvim-tree/nvim-tree.lua")
  -- use("kabouzeid/nvim-lspinstall")
  -- vs-code like icons
  use("kyazdani42/nvim-web-devicons")

  -- statusline
  use("nvim-lualine/lualine.nvim")

  -- fuzzy finding w/ telescope
  -- use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- dependency for better sorting performance
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    -- or                            , branch = '0.1.x',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }
  use({ "akinsho/bufferline.nvim", tag = "v2.*", requires = "kyazdani42/nvim-web-devicons" })
  use('norcalli/nvim-colorizer.lua')
  -- autocompletion
  use("hrsh7th/nvim-cmp") -- completion plugin
  use("hrsh7th/cmp-buffer") -- source for text in buffer
  use("hrsh7th/cmp-path") -- source for file system paths
  use("hrsh7th/cmp-nvim-lsp") -- for autocompletion
  use("neovim/nvim-lspconfig") -- easily configure language servers

  -- snippets
  use("L3MON4D3/LuaSnip") -- snippet engine
  use("saadparwaiz1/cmp_luasnip") -- for autocompletion
  use("rafamadriz/friendly-snippets") -- useful snippets
  use('SirVer/ultisnips')
  use('honza/vim-snippets')
  -- use("quangnguyen30192/cmp-nvim-ultisnips")

  -- managing & installing lsp servers, linters & formatters
  use("williamboman/mason.nvim") -- in charge of managing lsp servers, linters & formatters
  use("williamboman/mason-lspconfig.nvim") -- bridges gap b/w mason & lspconfig

  -- configuring lsp servers
  use("glepnir/lspsaga.nvim")
  use("jose-elias-alvarez/typescript.nvim") -- additional functionality for typescript server (e.g. rename file & update imports)
  use("onsails/lspkind.nvim") -- vs-code like icons for autocompletion

  -- formatting & linting
  -- use("jose-elias-alvarez/null-ls.nvim") -- configure formatters & linters
  -- use("jayp0521/mason-null-ls.nvim") -- bridges gap b/w mason & null-ls

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use "mhartington/formatter.nvim"

  -- auto closing
  use("windwp/nvim-autopairs") -- autoclose parens, brackets, quotes, etc...
  use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" }) -- autoclose tags

  -- git integration
  use("lewis6991/gitsigns.nvim") -- show line modifications on left hand side
  use("tpope/vim-fugitive")
  use("akinsho/toggleterm.nvim")
  use("goolord/alpha-nvim")
  use("ahmedkhalf/project.nvim")
  use("Pocco81/auto-save.nvim")
  use "lukas-reineke/indent-blankline.nvim"
  if packer_bootstrap then
    require("packer").sync()
  end
end)
