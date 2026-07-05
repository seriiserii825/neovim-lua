return {
  {
    "github/copilot.vim",
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
    config = function()
      -- copilot#Accept() returns a raw keystroke sequence (<C-R><C-R>=...<CR>)
      -- that Vim's own <expr> mapping machinery must re-feed and expand; doing
      -- this via vim.keymap.set's Lua string escaping mangled it into literal
      -- garbage bytes, so define it exactly as the plugin's own docs show it,
      -- via a real vimscript :imap.
      vim.cmd([[imap <silent><script><expr> <C-l> copilot#Accept("\<CR>")]])
      vim.keymap.set("i", "<M-;>", "<Plug>(copilot-next)")
      vim.keymap.set("i", "<M-,>", "<Plug>(copilot-suggest)")

      vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>")
      vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>")
    end,
  },
}
