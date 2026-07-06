return {
  {
    "hrsh7th/nvim-cmp",
    -- Completion is only relevant in insert mode; deferring load here (and on
    -- ultisnips.lua, same event) skips ~150ms+ of cmp/cmp-source requires on
    -- every startup, moving them to the first InsertEnter instead.
    event = "InsertEnter",
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

      -- cmp-nvim-ultisnips' own source:execute() (lua/cmp_nvim_ultisnips/source.lua)
      -- ignores which candidate cmp actually resolved and just calls the raw
      -- UltiSnips#ExpandSnippet(), which re-matches the trigger text against
      -- ALL known snippets from scratch -- reintroducing the exact ambiguous
      -- "Confirm" chooser (e.g. "v" vs "dv") that going through cmp's own
      -- prefix-filtered candidate list was supposed to avoid, and can wedge
      -- the buffer/statusline if you answer that chooser mid-insert. Patch it
      -- to delete the trigger text cmp just inserted and expand the already-
      -- resolved snippet body directly via UltiSnips#Anon instead -- no
      -- re-matching, no ambiguity.
      --
      -- The actual buffer edit + UltiSnips#Anon call is deferred one event
      -- loop tick via vim.schedule(): UltiSnips is a python remote plugin, so
      -- calling into it is an RPC round trip, not a plain Lua call. Doing that
      -- synchronously inside cmp's own execute()/confirm_done handling raced
      -- with cmp still tearing down its popup/redraw for that same keystroke,
      -- which corrupted the screen (garbled lines, bufferline vanishing).
      -- Scheduling it lets cmp finish its frame first.
      local ok, cmpu_source = pcall(require, "cmp_nvim_ultisnips.source")
      if ok then
        cmpu_source.execute = function(_, completion_item, callback)
          vim.schedule(function()
            local snippet = completion_item.snippet
            local cursor = vim.api.nvim_win_get_cursor(0)
            local row, col = cursor[1] - 1, cursor[2]
            local inserted_len = #(completion_item.insertText or snippet.trigger)
            vim.api.nvim_buf_set_text(0, row, col - inserted_len, row, col, { "" })
            vim.fn["UltiSnips#Anon"](snippet.value)
          end)
          callback(completion_item)
        end
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["UltiSnips#Anon"](args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          -- select = false: only confirm a completion if the user explicitly
          -- picked one (via <C-j>/<C-k>). Otherwise <CR> just inserts a
          -- newline, even while cmp's popup happens to be open with an
          -- unselected candidate (e.g. emmet_language_server keeps a popup
          -- alive between an expanded tag's open/close, like
          -- <div class="x">|</div> — select = true used to auto-confirm
          -- that stray candidate and duplicate the closing tag).
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ select = false })
            else
              fallback()
            end
          end, { "i", "s" }),
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
          -- confirming it instead sidesteps that -- and the source:execute()
          -- patch above ensures *confirming* doesn't quietly reintroduce the
          -- same ambiguity underneath.
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
