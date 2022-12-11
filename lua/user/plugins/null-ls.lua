require("null-ls").setup({
  sources = {
    require("null-ls").builtins.formatting.shfmt, -- shell script formatting
    require("null-ls").builtins.formatting.prettier, -- markdown formatting
    require("null-ls").builtins.diagnostics.shellcheck, -- shell script diagnostics
  },
})

vim.cmd('map <Leader>F :lua vim.lsp.buf.format()<CR>')
