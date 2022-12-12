local ls = require("luasnip") --{{{

-- require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
require("luasnip").config.setup({ store_selection_keys = "<A-p>" })


