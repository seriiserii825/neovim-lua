return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "typescript",
          "tsx",
          "javascript",
          "html",
          "css",
          "scss",
          "json",
          "lua",
          "vim",
          "vimdoc",
          "markdown",
          "markdown_inline",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
