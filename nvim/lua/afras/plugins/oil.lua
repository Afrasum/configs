return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local oil = require("oil")

		oil.setup({
			-- Oil vil erstatte netrw, men siden du har nvim-tree kan du velge
			default_file_explorer = false,

			-- Columns å vise i oil buffer
			columns = {
				"icon",
				-- "permissions",
				-- "size",
				-- "mtime",
			},

			-- Buffer-lokale options å sette for oil buffers
			buf_options = {
				buflisted = false,
				bufhidden = "hide",
			},

			-- Window-lokale options å sette for oil buffers
			win_options = {
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},

			-- Cleanup funksjoner for når oil buffer forlates
			delete_to_trash = false,
			skip_confirm_for_simple_edits = false,

			-- Keymaps i oil buffer
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Åpne split vertikalt" },
				["<C-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Åpne split horisontalt" },
				["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Åpne i ny tab" },
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-l>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = { "actions.cd", opts = { scope = "tab" }, desc = "cd i tab scope" },
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				["g\\"] = "actions.toggle_trash",
			},

			-- Sett til 'false' for å disable alt default keymaps
			use_default_keymaps = true,

			view_options = {
				-- Vis filer/mapper som starter med "."
				show_hidden = false,
				-- Denne funksjonen definerer hva som er "hidden"
				is_hidden_file = function(name, bufnr)
					return vim.startswith(name, ".")
				end,
				-- Denne funksjonen definerer hva som alltid skal vises
				is_always_hidden = function(name, bufnr)
					return false
				end,
				-- Natural sorting av filnavn (1, 2, 10 i stedet for 1, 10, 2)
				natural_order = true,
				-- Sorteringsmetode: "name", "type", "mtime", "size", "atime", "ctime", "birthtime", "extension"
				sort = {
					{ "type", "asc" },
					{ "name", "asc" },
				},
			},

			-- Konfigurasjon for floating window
			float = {
				padding = 2,
				max_width = 0,
				max_height = 0,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				-- Dette er default get_win_config, kan overstyres
				-- return type: win_config. Se :h nvim_open_win
				get_win_config = nil,
			},

			-- Konfigurasjon for preview window
			preview = {
				max_width = 0.9,
				min_width = { 40, 0.4 },
				width = nil,
				max_height = 0.9,
				min_height = { 5, 0.1 },
				height = nil,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				-- Om du vil at preview vinduet skal oppdateres automatisk
				update_on_cursor_moved = true,
			},

			-- Konfigurasjon for progress window
			progress = {
				max_width = 0.9,
				min_width = { 40, 0.4 },
				width = nil,
				max_height = { 10, 0.9 },
				min_height = { 5, 0.1 },
				height = nil,
				border = "rounded",
				minimized_border = "none",
				win_options = {
					winblend = 0,
				},
			},

			-- EXPERIMENTAL support for performing file operations with git
			git = {
				add = function(path)
					return false
				end,
				mv = function(src_path, dest_path)
					return false
				end,
				rm = function(path)
					return false
				end,
			},

			-- EXPERIMENTAL support for sending LSP file operations
			lsp_file_methods = {
				-- Time to wait for LSP file operations to complete before timing out
				timeout_ms = 1000,
				-- Set to true to autosave buffers that are updated with LSP willRenameFiles
				autosave_changes = false,
			},

			-- Cleanup funksjoner når oil buffer forlates
			cleanup_delay_ms = 2000,
		})

		-- Keymaps
		local keymap = vim.keymap

		keymap.set("n", "<leader>eo", "<cmd>Oil<CR>", { desc = "Åpne Oil i current dir" })
		keymap.set("n", "<leader>eO", "<cmd>Oil --float<CR>", { desc = "Åpne Oil i floating window" })
		keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Åpne parent directory" })
	end,
}
