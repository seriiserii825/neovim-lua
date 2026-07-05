return {
  {
    "vim-airline/vim-airline",
    init = function()
      vim.g["airline#extensions#tabline#enabled"] = 0
      vim.g["airline#extensions#tabline#left_sep"] = ""
      vim.g["airline#extensions#tabline#left_alt_sep"] = ""
      vim.g["airline#extensions#tabline#right_sep"] = ""
      vim.g["airline#extensions#tabline#right_alt_sep"] = ""

      vim.g.airline_powerline_fonts = 1
      vim.g.airline_left_sep = ""
      vim.g.airline_right_sep = ""

      vim.g.airline_section_z = ""

      vim.opt.showtabline = 2
      vim.opt.showmode = false
    end,
  },
}
