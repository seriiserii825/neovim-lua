return {
  {
    "AlexvZyl/nordic.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nordic").setup({
        on_highlight = function(highlights)
          highlights.Visual = { bg = "#3d59a1" }
        end,
      })
      require("nordic").load()
    end,
  },
}
