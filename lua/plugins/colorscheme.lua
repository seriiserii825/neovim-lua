return {
  {
    "AlexvZyl/nordic.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nordic").setup({
        on_highlight = function(highlights)
          highlights.Visual = { bg = "#2E4075" }
        end,
      })
      require("nordic").load()
    end,
  },
}
