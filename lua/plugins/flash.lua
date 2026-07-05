return {
  {
    "folke/flash.nvim",
    config = function()
      require("flash").setup()

      vim.keymap.set("n", "s", function()
        require("flash").jump()
      end)
      vim.keymap.set("n", "<leader>ft", function()
        require("flash").toggle()
      end)
      vim.keymap.set("o", "r", function()
        require("flash").remote()
      end)
    end,
  },
}
