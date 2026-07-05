return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({})

      -- moved under <leader>t: fzf.vim now owns <leader>f* (see fzf.lua) to match the old build's muscle memory
      vim.keymap.set("n", "<leader>tf", builtin.find_files, { desc = "Telescope find files" })
      vim.keymap.set("n", "<leader>tb", builtin.buffers, { desc = "Telescope buffers" })
      vim.keymap.set("n", "<leader>tg", builtin.live_grep, { desc = "Telescope live grep" })
      vim.keymap.set("n", "<leader>th", builtin.help_tags, { desc = "Telescope help tags" })
    end,
  },
}
