-- ~/.config/nvim/lua/plugins/copilot-chat.lua
return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		"github/copilot.vim", -- eller zbirenbaum/copilot.lua
		"nvim-lua/plenary.nvim", -- behøves av CopilotChat
	},
	cmd = { "CopilotChat", "CopilotChatToggle", "CopilotChatExplain" },
	event = "VeryLazy",

	-- ░█▀▄░█▀▀░█▀▀░▀█▀░█▀█░█░█
	-- ░█▀▄░█▀▀░█░░░░█░░█▀█░█░█
	-- ░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀▀▀
	opts = {
		---------------------------------------------------------------------------
		-- 1.  Felles (kan endres i runtime med API-kall)
		---------------------------------------------------------------------------
		system_prompt = "COPILOT_INSTRUCTIONS",
		model = "gpt-4.1",
		agent = "copilot",
		context = nil, -- f.eks. { "buffer", "git:staged" }
		sticky = nil, -- f.eks. { "@models Using GPT-4o", "#files" }

		temperature = 0.1,
		headless = false,
		stream = nil, -- fun(str) -> str
		callback = nil, -- fun(str) -> str
		remember_as_sticky = true,

		---------------------------------------------------------------------------
		-- 2.  Vindu
		---------------------------------------------------------------------------
		window = {
			layout = "vertical", -- vertical | horizontal | float | replace | fun()
			width = 0.5, -- relativt (<1) eller absolutt (>1)
			height = 0.5,
			relative = "editor", -- editor | win | cursor | mouse
			border = "single", -- none | single | double | rounded | solid | shadow
			row = nil,
			col = nil,
			title = "Copilot Chat",
			footer = nil,
			zindex = 1,
		},

		---------------------------------------------------------------------------
		-- 3.  UI-flagg
		---------------------------------------------------------------------------
		show_help = true,
		highlight_selection = true,
		highlight_headers = true,
		references_display = "virtual", -- virtual | write
		auto_follow_cursor = true,
		auto_insert_mode = false,
		insert_at_end = false,
		clear_chat_on_new_prompt = false,

		---------------------------------------------------------------------------
		-- 4.  Statisk (kun via setup)
		---------------------------------------------------------------------------
		debug = false,
		log_level = "info", -- trace | debug | info | warn | error | fatal
		log_path = vim.fn.stdpath("state") .. "/copilot-chat.log",
		proxy = nil, -- "http://proxy:port"
		allow_insecure = false,
		chat_autocomplete = true,

		---------------------------------------------------------------------------
		-- 5.  Tastatursnarveier (full liste av default-mappingene)
		---------------------------------------------------------------------------
		mappings = {
			-- Navigasjon
			close = { normal = "q", insert = "<C-c>" },
			scroll_up = { normal = "<C-u>", insert = "<C-u>" },
			scroll_down = { normal = "<C-d>", insert = "<C-d>" },

			-- Prompt
			submit_prompt = { normal = "<CR>", insert = "<CR>" },
			complete = { normal = "<Tab>", insert = "<Tab>" },

			-- Handlinger
			reset = { normal = "<leader>cr" },
			toggle = { normal = "<leader>cc" },

			-- Diff/hjelp
			show_diff = { normal = "gd", full_diff = false },
			yank_diff = { normal = "gy" },
			show_info = { normal = "gi" },
			show_context = { normal = "gc" },
			show_help = { normal = "gh" },
		},

		---------------------------------------------------------------------------
		-- 6.  Ferdige prompt-maler (kan erstattes/utvides)
		---------------------------------------------------------------------------
	},

	-- ░█▀▄░█▀▀░█▀▀░█▀▀
	-- ░█░█░█▀▀░█▀▀░▀▀█
	-- ░▀▀░░▀▀▀░▀▀▀░▀▀▀
	config = function(_, opts)
		require("CopilotChat").setup(opts)

		-- Ekstra keymaps (tilpass etter behov)
		vim.keymap.set("n", "<leader>cc", "<cmd>CopilotChatToggle<CR>", { desc = "Toggle Copilot-chat" })

		vim.keymap.set("n", "<leader>ca", function()
			local q = vim.fn.input("Copilot-chat: ")
			if q ~= "" then
				require("CopilotChat").ask(q, {
					selection = require("CopilotChat.select").buffer,
				})
			end
		end, { desc = "Copilot-chat (buffer)" })

		vim.keymap.set("v", "<leader>ce", "<cmd>CopilotChatExplain<CR>", { desc = "Copilot: forklar utvalg" })
	end,
}
