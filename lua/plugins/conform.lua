return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      local ok, mason_registry = pcall(require, "mason-registry")
      if ok and not mason_registry.is_installed("prettier") then
        mason_registry.get_package("prettier"):install()
      end

      local prettier_fts = {
        "html",
        "css",
        "scss",
        "json",
        "jsonc",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "yaml",
        "markdown",
      }

      local formatters_by_ft = {}
      for _, ft in ipairs(prettier_fts) do
        formatters_by_ft[ft] = { "prettier" }
      end

      require("conform").setup({
        formatters_by_ft = formatters_by_ft,
        format_on_save = {
          timeout_ms = 2000,
          lsp_format = "fallback", -- e.g. angularls/ts_ls for filetypes with no prettier entry
        },
      })
    end,
  },
}
