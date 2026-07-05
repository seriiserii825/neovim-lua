return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({})

      vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>h", builtin.help_tags, { desc = "Help tags" })
    end,
  },
}
