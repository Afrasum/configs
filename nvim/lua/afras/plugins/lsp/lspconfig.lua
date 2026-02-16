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
		-- Hjelpefunksjon: Restart LSP uten Copilot
		---------------------------------------------------------------------------
		local function restart_lsp_safe()
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			local excluded_patterns = { "copilot", "GitHub Copilot" }
			local restarted = false

			for _, client in ipairs(clients) do
				local should_exclude = false
				for _, pattern in ipairs(excluded_patterns) do
					if client.name:lower():find(pattern:lower()) then
						should_exclude = true
						break
					end
				end

				if not should_exclude then
					local client_id = client.id
					vim.lsp.stop_client(client_id, true)
					vim.defer_fn(function()
						-- Lagre først hvis det er endringer
						if vim.bo.modified then
							vim.cmd("write")
						end
						vim.cmd("edit")
					end, 100)
					restarted = true
				end
			end

			if restarted then
				print("LSP restarted (excluding Copilot)")
			else
				print("No LSP servers to restart")
			end
		end

		vim.api.nvim_create_user_command("LspRestartSafe", restart_lsp_safe, {
			desc = "Restart LSP servers except Copilot",
		})

		---------------------------------------------------------------------------
		-- Buffer-lokale tastatursnarveier for LSP
		---------------------------------------------------------------------------
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client then
					if client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					end
					if client.server_capabilities.semanticTokensProvider then
						vim.lsp.semantic_tokens.start(ev.buf, client.id)
					end
				end

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
				keymap.set("n", "<leader>rs", ":LspRestartSafe<CR>", opts)
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

				["pyright"] = function()
					-- Finn Python path - venv-selector setter VIRTUAL_ENV
					local function get_python_path(workspace)
						-- 1. VIRTUAL_ENV satt av venv-selector eller manuell aktivering
						if vim.env.VIRTUAL_ENV then
							return vim.env.VIRTUAL_ENV .. "/bin/python"
						end

						-- 2. Fallback: sjekk for .venv i workspace
						if vim.fn.executable(workspace .. "/.venv/bin/python") == 1 then
							return workspace .. "/.venv/bin/python"
						end

						-- 3. Fallback: sjekk for venv i workspace
						if vim.fn.executable(workspace .. "/venv/bin/python") == 1 then
							return workspace .. "/venv/bin/python"
						end

						return nil
					end

					lspconfig.pyright.setup({
						capabilities = capabilities,
						before_init = function(_, config)
							-- Sett Python path før LSP starter
							local python_path = get_python_path(config.root_dir)
							if python_path then
								config.settings.python.pythonPath = python_path
							end
						end,
						settings = {
							python = {
								analysis = {
									autoSearchPaths = true,
									useLibraryCodeForTypes = true,
									diagnosticMode = "workspace",
								},
							},
							-- Disable organize imports since Ruff handles it
							pyright = {
								disableOrganizeImports = true,
							},
						},
					})
				end,

				["clangd"] = function()
					lspconfig.clangd.setup({
						capabilities = capabilities,
						cmd = {
							"clangd",
							"--background-index",
							"--clang-tidy",
							"--header-insertion=iwyu",
							"--completion-style=detailed",
							"--function-arg-placeholders",
							"--fallback-style=llvm",
						},
						init_options = {
							usePlaceholders = true,
							completeUnimported = true,
							clangdFileStatus = true,
						},
					})
				end,

				["gopls"] = function()
					lspconfig.gopls.setup({
						capabilities = capabilities,
						settings = {
							gopls = {
								analyses = {
									unusedparams = true,
									shadow = true,
									nilness = true,
									unusedwrite = true,
									useany = true,
								},
								staticcheck = true,
								gofumpt = true,
								usePlaceholders = true,
								completeUnimported = true,
								hints = {
									assignVariableTypes = true,
									compositeLiteralFields = true,
									compositeLiteralTypes = true,
									constantValues = true,
									functionTypeParameters = true,
									parameterNames = true,
									rangeVariableTypes = true,
								},
							},
						},
					})
				end,

				-- legg til prismals, tsserver, osv. her om du trenger egne innstillinger
			},
		})
	end,
}
