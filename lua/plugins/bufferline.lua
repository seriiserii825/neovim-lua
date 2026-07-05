return {
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          numbers = "none",
          close_command = "bdelete! %d",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          max_name_length = 18,
          max_prefix_length = 15,
          tab_size = 18,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, _level, _diagnostics_dict, _context)
            return "(" .. count .. ")"
          end,
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = false,
          show_close_icon = false,
          show_tab_indicators = true,
          persist_buffer_sort = true,
          separator_style = "thick",
          enforce_regular_tabs = true,
          always_show_bufferline = true,
          sort_by = "insert_after_current",
        },
      })

      local map = vim.keymap.set

      map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { silent = true })
      map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { silent = true })
      map("n", "<M-S-l>", "<cmd>BufferLineMoveNext<CR>", { silent = true })
      map("n", "<M-S-h>", "<cmd>BufferLineMovePrev<CR>", { silent = true })
      map("n", "<leader>qr", "<cmd>BufferLineCloseRight<CR>", { silent = true })
      map("n", "<leader>qa", "<cmd>BufferLineCloseOther<CR>", { silent = true })

      for i = 1, 9 do
        map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>")
      end
      map("n", "<leader>0", "<cmd>BufferLineGoToBuffer 0<CR>")
    end,
  },
}
