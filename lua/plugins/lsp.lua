return {
  {
    "neovim/nvim-lspconfig",
    -- mason.setup()/mason-lspconfig.setup() alone cost ~250ms+ (dozens of
    -- mason-core.* requires) on every startup, even when editing a filetype
    -- none of the configured servers (ts_ls/angularls/emmet/intelephense/
    -- vue_ls) touch -- e.g. this repo's own *.lua files. Restricting to the
    -- filetypes those servers actually attach to means opening a Lua/Python/
    -- shell/etc buffer skips this whole cost entirely.
    ft = {
      "javascript", "javascriptreact", "typescript", "typescriptreact", "vue",
      "html", "htmlangular", "htmldjango", "astro",
      "css", "scss", "sass", "less", "eruby", "svelte",
      "php", "blade", "php.blade", "markdown",
    },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- TypeScript / JavaScript. Also attaches to *.vue files (with the
      -- @vue/typescript-plugin loaded) since vue_ls itself only handles the
      -- template/CSS side and forwards all <script> TS requests to this
      -- server -- see lsp/vue_ls.lua's "hybrid mode" note in nvim-lspconfig.
      local vue_typescript_plugin = vim.fn.stdpath("data")
        .. "/mason/packages/vue-language-server/node_modules/@vue/typescript-plugin"
      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = vue_typescript_plugin,
              languages = { "vue" },
            },
          },
        },
      })

      -- Vue 3. Handles the template/CSS side of *.vue files; ts_ls (above)
      -- handles the <script> side via the forwarded @vue/typescript-plugin.
      vim.lsp.config("vue_ls", {
        capabilities = capabilities,
      })

      -- angularls ships its own default `cmd` (lsp/angularls.lua in nvim-lspconfig)
      -- that resolves the correct node_modules paths via the ngserver binary itself,
      -- so it doesn't need to be overridden here.
      vim.lsp.config("angularls", {
        capabilities = capabilities,
      })

      -- Emmet abbreviation completion. Extends nvim-lspconfig's default filetypes
      -- (astro/css/eruby/html/htmlangular/htmldjango/jsx/less/sass/scss/svelte/tsx/vue)
      -- with the languages the old CoC build treated as html for emmet purposes
      -- (coc-settings.json's emmet.includeLanguages: php/blade/blade.php/vue/markdown).
      vim.lsp.config("emmet_language_server", {
        capabilities = capabilities,
        filetypes = {
          "astro", "css", "eruby", "html", "htmlangular", "htmldjango",
          "javascriptreact", "less", "sass", "scss", "svelte", "typescriptreact", "vue",
          "php", "blade", "php.blade", "markdown",
        },
      })

      -- PHP (WordPress). Mirrors the old CoC build's intelephense settings
      -- (coc-settings.json): WordPress/plugin stubs for completion, format on
      -- save enabled, and *.blade.php attached too (it's set to filetype
      -- "php.blade" in ultisnips.lua, so the default {"php"} filetypes list
      -- alone would miss it).
      vim.lsp.config("intelephense", {
        capabilities = capabilities,
        filetypes = { "php", "php.blade" },
        settings = {
          intelephense = {
            files = {
              maxSize = 5000000,
              exclude = {
                "**/.git/**",
                "**/.svn/**",
                "**/.hg/**",
                "**/CVS/**",
                "**/.DS_Store/**",
                "**/node_modules/**",
                "**/bower_components/**",
                "**/vendor/**/{Tests,tests}/**",
                "**/.history/**",
                "**/vendor/**/vendor/**",
                "**/docker/**",
              },
            },
            environment = {
              includePaths = {
                "/home/serii/Documents/plugins-wp/advanced-custom-fields-pro",
                "/home/serii/Documents/wordpress/wordpress",
                "/home/serii/Documents/wordpress/woocommerce",
                "/home/serii/Documents/wordpress/wp-pagenavi",
              },
            },
            format = { enable = true },
            diagnostics = {
              typeErrors = true,
              unusedSymbols = true,
              undefinedVariables = true,
            },
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "angularls", "emmet_language_server", "intelephense", "vue_ls" },
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
            require("conform").format({ async = true, lsp_format = "fallback" })
          end)
          map("n", "[g", vim.diagnostic.goto_prev)
          map("n", "]g", vim.diagnostic.goto_next)
          map("n", "<leader>cp", vim.diagnostic.open_float)

          -- Mirrors the old coc.vim build's fix_all_imports(): add missing
          -- imports, then remove unused ones, then organize -- each step run
          -- after the previous one's edit has actually applied, since these
          -- are separate LSP requests/edits rather than one atomic action.
          map("n", "<leader>ia", function()
            local function apply_kind(kind, on_done)
              vim.lsp.buf.code_action({
                context = { only = { kind }, diagnostics = {} },
                apply = true,
              })
              vim.defer_fn(on_done or function() end, 100)
            end
            apply_kind("source.addMissingImports.ts", function()
              apply_kind("source.removeUnused.ts", function()
                apply_kind("source.organizeImports")
              end)
            end)
          end)
        end,
      })
    end,
  },
}
