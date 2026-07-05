vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smarttab = true
opt.autoindent = true
opt.smartindent = true
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 300
opt.foldmethod = "indent"
opt.foldenable = true
opt.foldnestmax = 20
opt.foldlevelstart = 99
opt.scrolloff = 2
opt.wrap = false

opt.textwidth = 0
opt.wrapmargin = 0
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true
opt.hidden = true
opt.inccommand = "nosplit"
opt.pumheight = 10
opt.fileencoding = "utf-8"
opt.ruler = true
opt.cmdheight = 1
opt.iskeyword:append("-")
opt.mouse = "a"
opt.conceallevel = 0
opt.cursorline = true
opt.cursorcolumn = true
opt.background = "dark"
opt.laststatus = 0 -- vim-airline forces this back to 2 once it attaches
opt.timeoutlen = 500
opt.formatoptions:remove({ "c", "r", "o" })

vim.api.nvim_create_autocmd("FocusLost", {
  command = "silent! wall",
})

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.opt.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.opt.relativenumber = true
  end,
})
