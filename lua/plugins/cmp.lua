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
        -- nvim-cmp defaults completeopt to "...,noselect", so the popup opens
        -- with nothing highlighted until <C-j>/<C-k> is pressed. coc's pum.vim
        -- auto-highlights the first candidate as soon as the menu appears;
        -- dropping "noselect" (keeping "noinsert") matches that -- first entry
        -- is pre-selected for visual/confirm purposes, but its text isn't
        -- spliced into the buffer until confirmed.
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
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
          -- <Tab> is deliberately NOT bound here -- it's left to fall through
          -- natively to UltiSnips' own <expr> mapping (g:UltiSnipsExpandTrigger
          -- / JumpForwardTrigger = "<Tab>", set in ultisnips.lua), exactly like
          -- the old coc.nvim build (modules/coc.vim there confirms its popup on
          -- <CR>/<C-j>/<C-n>, never <Tab>; UltiSnips owns <Tab> outright).
          --
          -- An earlier version of this config routed <Tab> through cmp.confirm
          -- instead, reasoning that UltiSnips' raw suffix-matching can't always
          -- tell "v" from "dv" and throws up an ambiguous "Confirm" chooser.
          -- That's real but rare and harmless (pick a number, move on). Routing
          -- through cmp to dodge it was much worse: while editing a snippet's
          -- $1 (e.g. dv's "div" tag-name placeholder), typing text that also
          -- happens to match another completion source's candidate -- notably
          -- emmet_language_server offering a full "<h2></h2>" for "h2" -- made
          -- cmp.visible() true, and <Tab> confirmed *that* instead of jumping
          -- to $2, silently splicing the emmet expansion into the middle of
          -- the snippet instead of jumping tabstops. Since UltiSnips' own
          -- ambiguity chooser only fires on genuine trigger collisions (a
          -- handful of snippets), while cmp's popup opens on nearly every
          -- keystroke, native <Tab> is the safer default.
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
        -- Snippet entries float to the top and Text entries (the buffer
        -- source's word-matches, labeled "Text" in the popup) sink to the
        -- bottom, regardless of what the default score-based ordering would
        -- pick -- everything else keeps cmp's normal comparator chain.
        sorting = {
          comparators = {
            function(entry1, entry2)
              local kind1 = entry1:get_kind()
              local kind2 = entry2:get_kind()
              local snippet_kind = cmp.lsp.CompletionItemKind.Snippet
              if kind1 == snippet_kind and kind2 ~= snippet_kind then
                return true
              elseif kind2 == snippet_kind and kind1 ~= snippet_kind then
                return false
              end
            end,
            function(entry1, entry2)
              local kind1 = entry1:get_kind()
              local kind2 = entry2:get_kind()
              local text_kind = cmp.lsp.CompletionItemKind.Text
              if kind1 == text_kind and kind2 ~= text_kind then
                return false
              elseif kind2 == text_kind and kind1 ~= text_kind then
                return true
              end
            end,
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
      })
    end,
  },
}
