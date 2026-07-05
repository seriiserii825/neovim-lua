return {
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = {
            filetypes = { css = true, html = true, sass = true, scss = true, less = true, stylus = true },
          },
          RRGGBBAA = false,
          AARRGGBB = false,
          rgb_fn = false,
          hsl_fn = false,
          css = false,
          css_fn = false,
          mode = "background",
          tailwind = false,
          sass = { enable = false, parsers = { "css" } },
          virtualtext = "■",
          always_update = false,
        },
        buftypes = {},
      })
    end,
  },
}
