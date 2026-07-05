return {
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 40
      vim.g.db_ui_save_location = "~/.local/share/nvim-lua/db_ui"

      vim.g.dbs = {
        { name = "tea-stream-local", url = "postgresql://root:123456@localhost:5433/teastream" },
      }
    end,
    config = function()
      vim.keymap.set("n", "<leader>db", ":DBUIToggle<CR>")
      vim.keymap.set("n", "<leader>df", ":DBUIFindBuffer<CR>")
      vim.keymap.set("n", "<leader>dr", ":DBUIRenameBuffer<CR>")
      vim.keymap.set("n", "<leader>dq", ":DBUILastQueryInfo<CR>")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({
            sources = { { name = "vim-dadbod-completion" } },
          })
        end,
      })
    end,
  },
}
