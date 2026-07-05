return {
  {
    "folke/which-key.nvim",
    config = function()
      local wk = require("which-key")

      wk.setup({
        preset = "modern",
        win = {
          border = "rounded",
        },
      })

      wk.add({
        { "<leader>x", group = "cleanup" },
        { "<leader>xr", desc = "remove empty lines" },
        { "<leader>xl", desc = "remove leading whitespace" },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "which_key",
        callback = function()
          vim.cmd([[
            highlight WhichKey          guifg=#89b4fa gui=bold
            highlight WhichKeyGroup     guifg=#a6e3a1
            highlight WhichKeyDesc      guifg=#cdd6f4
            highlight WhichKeySeparator guifg=#6c7086
            highlight WhichKeyFloat     guibg=#1e1e2e
            highlight WhichKeyBorder    guifg=#89dceb
          ]])
        end,
      })
    end,
  },
}
