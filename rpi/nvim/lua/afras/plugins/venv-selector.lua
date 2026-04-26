return {
	"linux-cultist/venv-selector.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-telescope/telescope.nvim",
		"mfussenegger/nvim-dap-python",
	},
	config = function()
		require("venv-selector").setup({
			-- Navn på venv-mapper å lete etter
			name = {
				"venv",
				".venv",
				"env",
				".env",
			},

			-- Automatisk aktiver cached venv når du åpner Python-fil
			auto_refresh = true,
		})
	end,
	event = "VeryLazy", -- Lazy load plugin
	keys = {
		{ "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Velg Python venv" },
		{ "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Velg cached venv" },
	},
}
