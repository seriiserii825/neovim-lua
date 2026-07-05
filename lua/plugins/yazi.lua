return {
  {
    "mikavilpas/yazi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("yazi").setup({
        open_for_directories = false,
        keymaps = {
          show_help = "<F1>",
        },
      })

      vim.keymap.set("n", "<leader>e", function()
        require("yazi").yazi()
      end, { desc = "Open Yazi at current file" })

      vim.keymap.set("n", "<leader>cw", "<cmd>Yazi cwd<cr>", { desc = "Yazi: CWD" })
    end,
  },
}
