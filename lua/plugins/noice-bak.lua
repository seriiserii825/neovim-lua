return {
  {
    "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    enabled = false,
    config = function()
      require("noice").setup({
        lsp = {
          progress = {
            enabled = false,
          },
        },
      })
    end,
  },
}
