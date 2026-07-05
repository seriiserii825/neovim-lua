return {
  {
    "junegunn/fzf",
    build = ":call fzf#install()",
  },
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    init = function()
      vim.g.fzf_history_dir = "~/.local/share/fzf-history"
      vim.g.fzf_tags_command = "ctags -R"
      vim.g.fzf_layout = {
        up = "~90%",
        window = { width = 0.8, height = 0.8, yoffset = 0.5, xoffset = 0.5, highlight = "Todo", border = "sharp" },
      }

      vim.env.FZF_DEFAULT_OPTS = "--layout=reverse --info=inline --bind ctrl-n:down,ctrl-p:up"
      vim.env.FZF_DEFAULT_COMMAND = [[rg --files --hidden --no-ignore-vcs --glob "!.git" --glob "!node_modules" --glob "!vendor" --glob "!autoload" --glob "!storage" --glob "!dist" --glob "!.nuxt" --glob "!.next" --glob "!.output" --glob "!.idea" --glob "!venv" --glob "!.venv" --glob "!__pycache__" --glob "!.mypy_cache" --glob "!ranger"]]

      vim.g.fzf_colors = {
        fg = { "fg", "Normal" },
        bg = { "bg", "Normal" },
        hl = { "fg", "Comment" },
        ["fg+"] = { "fg", "CursorLine", "CursorColumn", "Normal" },
        ["bg+"] = { "bg", "CursorLine", "CursorColumn" },
        ["hl+"] = { "fg", "Statement" },
        info = { "fg", "PreProc" },
        border = { "fg", "Ignore" },
        prompt = { "fg", "Conditional" },
        pointer = { "fg", "Exception" },
        marker = { "fg", "Keyword" },
        spinner = { "fg", "Label" },
        header = { "fg", "Comment" },
      }
    end,
    config = function()
      vim.cmd([[
        command! -bang -nargs=? -complete=dir Files
          \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline']}), <bang>0)

        command! -bang -nargs=* Rg
          \ call fzf#vim#grep(
          \   "rg --column --line-number --no-heading --color=always --smart-case --max-columns=500"
          \   ." --glob '!*.lock' --glob '!*-lock.json' --glob '!*.min.js' --glob '!*.min.css'"
          \   ." --glob '!node_modules' --glob '!vendor' --glob '!dist' --glob '!storage' --glob '!.git' "
          \   .shellescape(<q-args>), 1,
          \   fzf#vim#with_preview(), <bang>0)

        function! RipgrepFzf(query, fullscreen)
          let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
          let initial_command = printf(command_fmt, shellescape(a:query))
          let reload_command = printf(command_fmt, '{q}')
          let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
          call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
        endfunction
        command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

        command! -bang -nargs=* GGrep
          \ call fzf#vim#grep(
          \   'git grep --line-number '.shellescape(<q-args>), 0,
          \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)
      ]])

      local map = vim.keymap.set

      map("n", "<leader>ff", ":Files<CR>")
      map("n", "<leader>fs", ":vs <bar> :Files<CR>")
      map("n", "<leader>fb", ":Buffers<CR>")
      -- open :Files pre-filled with the word under the cursor
      map("n", "<leader>fw", function()
        local word = vim.fn.expand("<cword>")
        vim.fn["fzf#vim#files"]("", vim.fn["fzf#vim#with_preview"]({ options = { "--query", word } }), 0)
      end)
      map("n", "<leader>fg", ':RG <C-r><C-w><CR>')
      map("n", "<leader>rg", ":RG<CR>")

      -- Git (fugitive + fzf)
      map("n", "<leader>fr", ":GFiles?<CR>")
      map("n", "<leader>fc", ":Commits<CR>")
      map("n", "<leader>fd", ":Gdiff<CR>")
      map("n", "<leader>fm", ":BCommits<CR>")

      map("n", "<leader>fv", function()
        vim.cmd("vs")
        vim.cmd("wincmd h")
        vim.defer_fn(function()
          vim.cmd("BufferLineCyclePrev")
        end, 100)
      end)
    end,
  },
}
