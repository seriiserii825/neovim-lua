return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- TypeScript / JavaScript
      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
      })

      -- Angular needs to be pointed at its own bundled node_modules
      -- (the language service ships inside the mason-installed package).
      local angular_probe = ""
      local ok, mason_registry = pcall(require, "mason-registry")
      if ok and mason_registry.is_installed("angular-language-server") then
        angular_probe = mason_registry.get_package("angular-language-server"):get_install_path() .. "/node_modules"
      end

      vim.lsp.config("angularls", {
        capabilities = capabilities,
        cmd = {
          "ngserver",
          "--stdio",
          "--tsProbeLocations",
          angular_probe,
          "--ngProbeLocations",
          angular_probe,
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "angularls" },
        automatic_enable = true,
      })

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map = function(mode, lhs, rhs)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
          end

          map("n", "K", vim.lsp.buf.hover)
          map("n", "gd", vim.lsp.buf.definition)
          map("n", "gy", vim.lsp.buf.type_definition)
          map("n", "gr", vim.lsp.buf.references)
          map("n", "gi", vim.lsp.buf.implementation)
          map("n", "<leader>rn", vim.lsp.buf.rename)
          map("n", "<leader>ca", vim.lsp.buf.code_action)
          map("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end)
          map("n", "[g", vim.diagnostic.goto_prev)
          map("n", "]g", vim.diagnostic.goto_next)
        end,
      })
    end,
  },
}
