-- ~/.config/nvim/lua/afras/plugins/lsp/lspconfig.lua
return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },

		-- sørg for at disse to er installert, ellers får du fortsatt feil
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
	},

	config = function()
		---------------------------------------------------------------------------
		-- Importer nødvendige moduler
		---------------------------------------------------------------------------
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap

		---------------------------------------------------------------------------
		-- Buffer-lokale tastatursnarveier for LSP
		---------------------------------------------------------------------------
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				opts.desc = "Vis referanser"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

				opts.desc = "Gå til deklarasjon"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				opts.desc = "Vis definisjoner"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

				opts.desc = "Vis implementasjoner"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

				opts.desc = "Vis type-definisjoner"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

				opts.desc = "Code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				opts.desc = "Rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				opts.desc = "Fil-diagnostikk"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

				opts.desc = "Linje-diagnostikk"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

				opts.desc = "Forrige diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

				opts.desc = "Neste diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

				opts.desc = "Hover-dokumentasjon"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})

		---------------------------------------------------------------------------
		-- Capabilities fra nvim-cmp
		---------------------------------------------------------------------------
		local capabilities = cmp_nvim_lsp.default_capabilities()

		---------------------------------------------------------------------------
		-- mason-lspconfig v3 → bruk `handlers`-API
		---------------------------------------------------------------------------
		mason_lspconfig.setup({
			-- automatic_installation = true | false kan settes her ved behov
			handlers = {
				-----------------------------------------------------------------------
				-- Standardoppsett for alle servere
				-----------------------------------------------------------------------
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,

				-----------------------------------------------------------------------
				-- Språkspesifikke overstyringer
				-----------------------------------------------------------------------
				["lua_ls"] = function()
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = { globals = { "vim" } },
								completion = { callSnippet = "Replace" },
							},
						},
					})
				end,

				["svelte"] = function()
					lspconfig.svelte.setup({
						capabilities = capabilities,
						on_attach = function(client, _)
							-- Hot-reload ved endring av JS/TS-filer
							vim.api.nvim_create_autocmd("BufWritePost", {
								pattern = { "*.js", "*.ts" },
								callback = function(ctx)
									client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
								end,
							})
						end,
					})
				end,

				["graphql"] = function()
					lspconfig.graphql.setup({
						capabilities = capabilities,
						filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
					})
				end,

				["emmet_ls"] = function()
					lspconfig.emmet_ls.setup({
						capabilities = capabilities,
						filetypes = {
							"html",
							"typescriptreact",
							"javascriptreact",
							"css",
							"sass",
							"scss",
							"less",
							"svelte",
						},
					})
				end,

				-- legg til prismals, tsserver, osv. her om du trenger egne innstillinger
			},
		})
	end,
}
