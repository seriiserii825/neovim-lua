return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      local ok, mason_registry = pcall(require, "mason-registry")
      if ok then
        for _, pkg in ipairs({ "prettier", "shfmt", "black" }) do
          if not mason_registry.is_installed(pkg) then
            mason_registry.get_package(pkg):install()
          end
        end
      end

      local prettier_fts = {
        "html",
        "htmlangular", -- Angular component templates (*.component.html) get this filetype, not "html"
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
      formatters_by_ft.sh = { "shfmt" }
      formatters_by_ft.bash = { "shfmt" }
      formatters_by_ft.python = { "black" }

      require("conform").setup({
        formatters_by_ft = formatters_by_ft,
        formatters = {
          black = {
            -- black's target-version auto-detection can guess a version newer
            -- than the interpreter running it, which then fails its own AST
            -- equivalence safety check ("Cannot parse for target version ...").
            -- --fast skips that check (black's own suggested workaround).
            prepend_args = { "--fast" },
          },
        },
        format_on_save = {
          timeout_ms = 2000,
          lsp_format = "fallback", -- e.g. angularls/ts_ls for filetypes with no prettier entry
        },
      })
    end,
  },
}
