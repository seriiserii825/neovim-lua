return {
  {
    "SirVer/ultisnips",
    dependencies = { "honza/vim-snippets" },
    init = function()
      -- Tab/S-Tab are driven through nvim-cmp (see cmp.lua); these triggers stay
      -- as a fallback for when the popup menu isn't visible.
      vim.g.UltiSnipsExpandTrigger = "<Tab>"
      vim.g.UltiSnipsJumpForwardTrigger = "<Tab>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<S-b>"

      vim.g.UltiSnipsSnippetDirectories = { "UltiSnips", "/home/serii/Documents/Apps/nvim/UltiSnips" }
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
