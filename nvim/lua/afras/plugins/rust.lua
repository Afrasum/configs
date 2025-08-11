return {
	"rust-lang/rust.vim",
	ft = "rust",
	init = function()
		-- Enable automatic rustfmt on save
		vim.g.rustfmt_autosave = 1

		-- Use rustfmt from the project if available
		vim.g.rustfmt_prefer_project_config = 1

		-- Don't backup files when running rustfmt
		vim.g.rustfmt_backup = 0

		-- Set Rust file type detection
		vim.g.rust_recommended_style = 1

		-- Enable folding for Rust files
		vim.g.rust_fold = 1
	end,
}