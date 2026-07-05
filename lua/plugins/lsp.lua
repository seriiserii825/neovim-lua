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

      -- angularls ships its own default `cmd` (lsp/angularls.lua in nvim-lspconfig)
      -- that resolves the correct node_modules paths via the ngserver binary itself,
      -- so it doesn't need to be overridden here.
      vim.lsp.config("angularls", {
        capabilities = capabilities,
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
          map("n", "<M-l>", function()
            vim.lsp.buf.format({ async = true })
          end)
          map("n", "[g", vim.diagnostic.goto_prev)
          map("n", "]g", vim.diagnostic.goto_next)
        end,
      })
    end,
  },
}
