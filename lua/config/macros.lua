-- Register-based macros ported byte-for-byte from the vimscript build's
-- modules/macros.vim and modules/macross-dir/*.vim (they contain raw
-- control characters, so they're kept as .vim files under ../macros and
-- just sourced here rather than retyped into Lua strings).
local macros_dir = vim.fn.stdpath("config") .. "/macros"

-- always-on generic macros (register a, c, d, f, j, k, l, m, n, p, s, t, u, v)
vim.cmd("source " .. macros_dir .. "/macros.vim")

-- language-specific macro sets reuse the same register letters (m, g, b, y, ...),
-- so only one is active at a time -- matching init.vim in the vimscript build,
-- where the others are commented out. Swap the active `source` line below to
-- switch sets.
vim.cmd("source " .. macros_dir .. "/bash-macros.vim")
-- vim.cmd("source " .. macros_dir .. "/python-macros.vim")
-- vim.cmd("source " .. macros_dir .. "/blade-macros.vim")
-- vim.cmd("source " .. macros_dir .. "/css-macros.vim")
