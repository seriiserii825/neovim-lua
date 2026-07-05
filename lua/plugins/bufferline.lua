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
      map("n", "<leader>qo", "<cmd>bp|sp|bn|bd<CR>", { silent = true })

      -- these three live alongside the bufferline binds in the vimscript build
      -- (modules/bufferline.vim), sourced after keys/map-nvim.vim -- so they win
      -- over map-nvim.vim's own <leader>w/<leader>z (see keymaps.lua note).
      map("n", "<leader>w", ":wa<CR>", { silent = true })
      map("n", "<leader>bo", ":only<CR>", { silent = true })
      map("n", "<leader>z", ":wq<CR>", { silent = true })

      for i = 1, 9 do
        map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>")
      end
      map("n", "<leader>0", "<cmd>BufferLineGoToBuffer 0<CR>")

      -- reload the current buffer from disk (bdelete + edit), keeping cursor position
      local function reload_current_buffer()
        local file = vim.fn.expand("%:p")
        local line = vim.fn.line(".")
        local col = vim.fn.col(".")

        if file == "" then
          vim.notify("Current buffer has no file")
          return
        end

        if vim.bo.modified then
          vim.cmd("write")
        end

        vim.cmd("bdelete! " .. vim.fn.bufnr("%"))
        vim.cmd("edit " .. vim.fn.fnameescape(file))

        vim.fn.cursor(line, col)
      end

      map("n", "<leader>br", reload_current_buffer, { silent = true })
    end,
  },
}
