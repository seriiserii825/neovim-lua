return {
  {
    "mikavilpas/yazi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- yazi.nvim ships its own lazy.lua spec with cmd-only triggers; force eager
    -- loading so our <leader>e / <leader>cw keymaps actually get registered.
    lazy = false,
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
