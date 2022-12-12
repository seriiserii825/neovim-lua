require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "sumneko_lua", "html" , "intelephense", "cssls", "tsserver", "vuels", "emmet_ls"}
})
