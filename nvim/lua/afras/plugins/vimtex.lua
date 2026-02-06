return {
	"lervag/vimtex",
	lazy = false, -- vimtex implements its own lazy loading via ftplugin
	init = function()
		-- Set localleader for vimtex commands
		vim.g.maplocalleader = ";"

		-- Use Skim as PDF viewer
		vim.g.vimtex_view_method = "skim"

		-- Compiler settings (latexmk is the default)
		vim.g.vimtex_compiler_method = "latexmk"

		-- Enable quickfix auto-open on compilation errors
		vim.g.vimtex_quickfix_mode = 1

		-- Disable overfull/underfull warnings in quickfix
		vim.g.vimtex_quickfix_ignore_filters = {
			"Underfull",
			"Overfull",
		}

		-- Enable folding (optional, set to 0 to disable)
		vim.g.vimtex_fold_enabled = 0

		-- Enable completion
		vim.g.vimtex_complete_enabled = 1

		-- Disable insert mode mappings (to avoid conflicts)
		vim.g.vimtex_imaps_enabled = 0

		-- Syntax concealment (0=off, 1=normal, 2=aggressive)
		vim.g.vimtex_syntax_conceal_disable = 0
	end,
	ft = { "tex", "bib" }, -- Load for tex and bib files
}
