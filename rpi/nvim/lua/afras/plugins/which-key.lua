return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500 -- du kan la denne stå som før
	end,
	opts = {
		-- Delay før popup vises, i millisekunder:
		delay = 2000,
	},
}
