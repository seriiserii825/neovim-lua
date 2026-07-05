return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "SirVer/ultisnips",
      "quangnguyen30192/cmp-nvim-ultisnips",
    },
    config = function()
      local cmp = require("cmp")

      -- "all" lists every snippet for the filetype and lets cmp's own fuzzy
      -- matching rank/filter by what you've typed; the default "expandable"
      -- mode asks UltiSnips itself which snippets could expand right now,
      -- which uses the same ambiguous suffix-matching that causes the
      -- "Confirm" chooser popup (e.g. triggers "v" and "dv" both matching).
      require("cmp_nvim_ultisnips").setup({ show_snippets = "all" })

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["UltiSnips#Anon"](args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          -- popup navigation lives on <C-j>/<C-k>, matching the CoC build's
          -- coc#pum#next/prev binding (see modules/coc.vim)
          ["<C-j>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-k>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          -- Tab never calls UltiSnips#ExpandSnippet directly: with triggers like
          -- "v" and "dv" both defined, UltiSnips can't tell which one you mean
          -- from raw suffix matching and throws up a "Confirm" chooser. Going
          -- through cmp's own (prefix-filtered, unambiguous) candidate list and
          -- confirming it instead sidesteps that entirely.
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            elseif vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
              vim.fn["UltiSnips#JumpForwards"]()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if vim.fn["UltiSnips#CanJumpBackwards"]() == 1 then
              vim.fn["UltiSnips#JumpBackwards"]()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "ultisnips" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}
