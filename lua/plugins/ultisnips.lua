return {
  {
    "SirVer/ultisnips",
    dependencies = { "honza/vim-snippets" },
    -- plugin/UltiSnips.vim alone costs ~200ms+ sourcing on every startup
    -- (scans all .snippets files); defer it to first insert since snippet
    -- expansion is only ever needed in insert mode anyway. `init` below still
    -- runs eagerly at startup (lazy.nvim always runs `init` immediately), so
    -- the *.blade.php filetype autocmd and g:UltiSnips* globals are set up
    -- before this ever matters.
    event = "InsertEnter",
    init = function()
      -- <Tab> is UltiSnips' own native trigger for both expand and jump-
      -- forward, same as the old coc.nvim build (modules/ulti-snippets.vim
      -- there). cmp.lua deliberately does NOT claim <Tab> for its own popup
      -- confirmation -- see the comment by nvim-cmp's mapping table for why
      -- that combination used to let stray completions (e.g. honza/vim-
      -- snippets' generic "h3" trigger) hijack <Tab> and corrupt an
      -- in-progress snippet.
      --
      -- g:UltiSnipsJumpOrExpandTrigger (NOT plain Expand+JumpForward set to
      -- the same key) is what actually matters here. UltiSnips'
      -- map_keys.vim picks the bound function by which globals exist:
      --   - only Expand/JumpForward set (even if equal) -> binds
      --     ExpandSnippetOrJump(), which calls _try_expand() FIRST and only
      --     falls back to _jump() if that fails.
      --   - JumpOrExpandTrigger set -> binds JumpOrExpandSnippet(), which
      --     calls _jump() FIRST and only falls back to _try_expand().
      -- With plain Expand/JumpForward (the first case), being mid-snippet on
      -- dv's $1 tag-name tabstop and typing "h3" made <Tab> try a fresh
      -- expand before checking whether a jump was possible -- and honza/
      -- vim-snippets (a dependency here, see below) ships its own generic
      -- "h3"/"h3."/"h3#" triggers matching that text exactly, so it expanded
      -- THAT in place of jumping to $2, splicing "<h3></h3>" into the
      -- snippet. JumpOrExpandTrigger fixes this by checking "am I already
      -- mid-snippet with somewhere to jump" first, which is what the old
      -- coc.nvim build's coc-snippets wrapper (g:coc_snippet_next = '<tab>')
      -- effectively did too -- it's an active-session-aware jump, not a
      -- fresh expand attempt.
      vim.g.UltiSnipsExpandTrigger = "<Tab>"
      vim.g.UltiSnipsJumpForwardTrigger = "<Tab>"
      vim.g.UltiSnipsJumpOrExpandTrigger = "<Tab>"
      -- Deliberately NOT <S-Tab>: cmp.lua binds a real <S-Tab> insert-mode
      -- keymap that calls UltiSnips#CanJumpBackwards/JumpBackwards directly,
      -- so backward-jump already works without a native trigger on the same
      -- key -- setting both would race two competing keymaps for <S-Tab>.
      vim.g.UltiSnipsJumpBackwardTrigger = "<S-b>"

      -- UltiSnips/ in this repo is a byte-for-byte copy of the vimscript
      -- build's snippets (kept in sync manually) -- self-contained on
      -- purpose, so this build doesn't depend on the other repo's absolute
      -- path existing on the machine (e.g. a work laptop that only has this repo).
      vim.g.UltiSnipsSnippetDirectories = { "UltiSnips" }
      vim.g.UltiSnipsFiletypeHierarchy = {
        ["php.blade"] = { "php", "html", "blade" },
      }

      vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
        pattern = "*.blade.php",
        callback = function()
          vim.bo.filetype = "php.blade"
        end,
      })
    end,
    config = function()
      vim.cmd([[
        function! s:SnipFtList()
          let ft = &filetype
          let hier = get(g:UltiSnipsFiletypeHierarchy, ft, [ft])
          if index(hier, ft) < 0 | call insert(hier, ft, 0) | endif
          return hier + ['all']
        endfunction

        function! s:BrowseSnippets()
          let dirs = g:UltiSnipsSnippetDirectories
          let fzf_lines = []

          for name in s:SnipFtList()
            for dir in dirs
              let fpath = dir . '/' . name . '.snippets'
              if !filereadable(fpath) | continue | endif

              let src   = fnamemodify(fpath, ':t:r')
              let fdata = readfile(fpath)
              let i     = 0

              while i < len(fdata)
                if fdata[i] =~# '^snippet\s'
                  let m = matchlist(fdata[i], '^snippet\s\+\(\S\+\)\s*\%("\([^"]*\)"\)\?')
                  if !empty(m)
                    let trigger = m[1]
                    let desc    = empty(m[2]) ? trigger : m[2]
                    let display = printf('%-20s  %-35s [%s]', trigger, desc, src)
                    call add(fzf_lines, display . "\t" . fpath . "\t" . (i + 1) . "\t" . trigger)
                  endif
                endif
                let i += 1
              endwhile
            endfor
          endfor

          if empty(fzf_lines)
            echo 'No snippets for: ' . &filetype
            return
          endif

          let preview = executable('bat')
            \ ? 'f={2}; l={3}; bat --style=plain --color=always --line-range=$l:$((l+30)) "$f"'
            \ : 'f={2}; l={3}; tail -n +$l "$f" | head -n 30'

          call fzf#run(fzf#wrap('snips', {
            \ 'source':  fzf_lines,
            \ 'sink':    function('s:SnipSink'),
            \ 'options': [
            \   '--prompt', &filetype . ' snips> ',
            \   '--delimiter', "\t",
            \   '--with-nth', '1',
            \   '--preview', preview,
            \   '--preview-window', 'right:55%:wrap',
            \   '--ansi',
            \ ],
            \ }))
        endfunction

        function! s:SnipSink(line)
          let parts = split(a:line, "\t")
          if len(parts) >= 4
            call feedkeys('a' . parts[3], 'n')
          endif
        endfunction

        command! SnipsBrowse call s:BrowseSnippets()
      ]])

      vim.keymap.set("n", "<leader>us", ":SnipsBrowse<CR>")
    end,
  },
}
