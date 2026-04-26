return {
	"chomosuke/typst-preview.nvim",
	lazy = false, -- Load immediately to ensure binaries are downloaded
	version = "1.*", -- Pin to major version 1
	ft = { "typst" }, -- Load for typst files
	opts = {
		-- Basic configuration
		follow_cursor = true, -- Preview scrolls with cursor (default: true)

		-- Uncomment to enable debug logging
		-- debug = true,

		-- Uncomment to specify a custom port (defaults to random)
		-- port = 3000,

		-- Uncomment to customize browser command
		-- open_cmd = "firefox %s",

		-- Invert colors for dark mode (options: 'never', 'auto')
		-- invert_colors = 'auto',
	},
}
