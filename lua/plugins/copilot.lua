return {
  {
    "github/copilot.vim",
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
    config = function()
      vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', { silent = true, expr = true })
      vim.keymap.set("i", "<M-;>", "<Plug>(copilot-next)")
      vim.keymap.set("i", "<M-,>", "<Plug>(copilot-suggest)")

      vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>")
      vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>")
    end,
  },
}
