return {
  {
    "nathanaelkane/vim-indent-guides",
    init = function()
      vim.g.indent_guides_auto_colors = 0
      vim.g.indent_guides_enable_on_vim_startup = 1
    end,
    config = function()
      vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
        callback = function()
          vim.cmd("hi IndentGuidesOdd guibg=#333934 ctermbg=3")
          vim.cmd("hi IndentGuidesEven guibg=#3C303D ctermbg=4")
        end,
      })
    end,
  },
}
