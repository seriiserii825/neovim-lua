return {
  {
    "sQVe/sort.nvim",
    config = function()
      require("sort").setup({
        delimiters = { ",", "|", ";", ":", "s", "t" },
      })

      vim.keymap.set("n", "go", "<Cmd>Sort<CR>", { silent = true })
      vim.keymap.set("v", "go", "<Esc><Cmd>Sort<CR>", { silent = true })
    end,
  },
}
