return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    config = function()
      vim.keymap.set("n", "<leader>sa", "<Plug>(VM-Select-All)<CR>")
    end,
  },
}
