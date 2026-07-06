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
        -- Only the plugins actually installed here need highlight-group
        -- integrations; nordic otherwise requires ~15 unused integration
        -- modules (nvim_tree, dashboard, mini, neorg, lsp_saga, nvim_dap,
        -- vimtex, trouble, leap, rainbow_delimiters, ...) on every startup.
        integrations = {
          dashboard = false,
          diff_view = false,
          gitsigns = true,
          indent_blankline = false,
          lazy = true,
          leap = false,
          lsp_saga = false,
          mini = false,
          neo_tree = false,
          neorg = false,
          noice = true,
          notify = true,
          nvim_cmp = true,
          blink_cmp = false,
          nvim_dap = false,
          nvim_tree = false,
          rainbow_delimiters = false,
          telescope = true,
          treesitter = true,
          treesitter_context = false,
          trouble = false,
          vimtex = false,
          visual_whitespace = false,
          which_key = true,
        },
      })
      require("nordic").load()
    end,
  },
}
