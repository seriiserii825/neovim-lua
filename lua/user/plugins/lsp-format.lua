-- Utilities for creating configurations
local util = require("formatter.util")

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup({
	-- Enable or disable logging
	logging = true,
	-- Set the log level
	log_level = vim.log.levels.WARN,
	-- All formatter configurations are opt-in
	filetype = {
		-- Formatter configurations for filetype "lua" go here
		-- and will be executed in order
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
		html = {
			require("formatter.filetypes.html").prettier,
		},
		php = {
			require("formatter.filetypes.php").intelephense,
		},
		scss = {
			require("formatter.filetypes.css").prettier,
		},
		css = {
			require("formatter.filetypes.css").prettier,
		},
		["*"] = {
			require("formatter.filetypes.any").prettier,
		},
	},
})
