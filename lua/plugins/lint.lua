return {
  {
    "mfussenegger/nvim-lint",
    dependencies = { "mason-org/mason.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ok, mason_registry = pcall(require, "mason-registry")
      if ok then
        mason_registry.refresh(function()
          if not mason_registry.is_installed("markdownlint-cli2") then
            local pkg_ok, package = pcall(mason_registry.get_package, "markdownlint-cli2")
            if pkg_ok then
              package:install()
            end
          end
        end)
      end

      local lint = require("lint")
      lint.linters_by_ft = {
        markdown = { "markdownlint-cli2" },
      }

      -- --config is independent of the "-" stdin input, so this applies our
      -- MD029 override (see markdownlint.jsonc) regardless of cwd.
      lint.linters["markdownlint-cli2"].args = {
        "--config",
        vim.fn.stdpath("config") .. "/markdownlint.jsonc",
        "-",
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
