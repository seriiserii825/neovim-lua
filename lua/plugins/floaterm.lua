return {
  {
    "voldikss/vim-floaterm",
    init = function()
      vim.g.floaterm_wintype = "float"
      vim.g.floaterm_width = 0.96
      vim.g.floaterm_height = 0.96
      vim.g.floaterm_keymap_toggle = "<C-;>"
    end,
  },
}
