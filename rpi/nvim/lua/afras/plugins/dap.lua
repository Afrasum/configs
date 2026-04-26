-- lua/plugins/dap.lua
return {

	-- 1. Hovedplugin: nvim-dap (DAP klient for Neovim)
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"jay-babu/mason-nvim-dap.nvim",
			"nvim-neotest/nvim-nio",
			"mfussenegger/nvim-dap-python",
		},
		config = function()
			local dap = require("dap")

			require("nvim-dap-virtual-text").setup()
			local dapui = require("dapui")
			dapui.setup({})

			dap.listeners.before.event_terminated["dapui_close"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_close"] = function()
				dapui.close()
			end

			require("mason-nvim-dap").setup({
				automatic_installation = true,
				handlers = {
					python = function(config) end,
				},
				ensure_installed = {
					"python",
					"codelldb",
					"cpptools",
					"js-debug-adapter",
					"delve", -- Go debugger
				},
			})

			if not dap.adapters["pwa-node"] then
				dap.adapters["pwa-node"] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
						args = {
							vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
							"${port}",
						},
					},
				}
			end
			if not dap.adapters["node"] then
				dap.adapters["node"] = function(cb, config)
					if config.type == "node" then
						config.type = "pwa-node"
					end
					local adapter = dap.adapters["pwa-node"]
					if type(adapter) == "function" then
						adapter(cb, config)
					else
						cb(adapter)
					end
				end
			end

			for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
				dap.configurations[language] = dap.configurations[language]
					or {
						{
							name = "Launch file",
							type = "pwa-node",
							request = "launch",
							program = "${file}",
							cwd = "${workspaceFolder}",
						},
						{
							name = "Attach",
							type = "pwa-node",
							request = "attach",
							processId = require("dap.utils").pick_process,
							cwd = "${workspaceFolder}",
						},
					}
			end

			dap.adapters.cppdbg = {
				id = "cppdbg",
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/bin/OpenDebugAD7",
			}
			dap.configurations.c = dap.configurations.c or {}
			dap.configurations.cpp = dap.configurations.cpp or {}
			local cpp_launch = {
				name = "Launch file",
				type = "cppdbg",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopAtEntry = false,
			}
			table.insert(dap.configurations.c, cpp_launch)
			table.insert(dap.configurations.cpp, cpp_launch)

			-- Go debugger configuration (Delve)
			dap.adapters.delve = {
				type = "server",
				port = "${port}",
				host = "127.0.0.1", -- Eksplisitt host for bedre kompatibilitet
				executable = {
					command = vim.fn.stdpath("data") .. "/mason/bin/dlv", -- Bruker Mason sin dlv
					args = { "dap", "-l", "127.0.0.1:${port}" },
				},
			}

			dap.configurations.go = {
				{
					type = "delve",
					name = "Debug",
					request = "launch",
					program = "${file}",
				},
				{
					type = "delve",
					name = "Debug test",
					request = "launch",
					mode = "test",
					program = "${file}",
				},
				{
					type = "delve",
					name = "Debug test (go.mod)",
					request = "launch",
					mode = "test",
					program = "./${relativeFileDirname}",
				},
			}

			-- Rust debugger configuration (CodeLLDB 1.11.0+ stdio mode - enklere og mer robust)
			-- Bruker stdio mode som er anbefalt fra CodeLLDB 1.11.0+
			dap.adapters.rust_codelldb = {
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
			}

			dap.configurations.rust = {
				{
					name = "Launch file",
					type = "rust_codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
				{
					name = "Attach to process",
					type = "rust_codelldb",
					request = "attach",
					pid = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
				},
			}

			local opts = { noremap = true, silent = true }
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, opts)
			vim.keymap.set("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Betingelse (Breakpoint condition): "))
			end, opts)
			vim.keymap.set("n", "<leader>dl", dap.run_last, opts)
			vim.keymap.set("n", "<leader>dc", dap.continue, opts)
			vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, opts)
			vim.keymap.set("n", "<leader>di", dap.step_into, opts)
			vim.keymap.set("n", "<leader>do", dap.step_out, opts)
			vim.keymap.set("n", "<leader>dO", dap.step_over, opts)
			vim.keymap.set("n", "<leader>dg", dap.goto_, opts)
			vim.keymap.set("n", "<leader>dT", dap.terminate, opts)
			vim.keymap.set("n", "<leader>dP", dap.pause, opts)
			vim.keymap.set("n", "<leader>dr", dap.repl.toggle, opts)
			vim.keymap.set("n", "<leader>ds", function()
				dap.close()
				dapui.close()
			end, opts)
			vim.keymap.set("n", "<leader>du", dapui.toggle, opts)
			vim.keymap.set("n", "<leader>dw", function()
				require("dap.ui.widgets").hover()
			end, opts)
			vim.keymap.set({ "n", "v" }, "<leader>de", function()
				dapui.eval()
			end, opts)
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		config = function(_, opts) end,
	},

	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		config = function()
			local dap_python = require("dap-python")
			local handle = io.popen("uv python find")
			local python_path = handle:read("*a"):gsub("%s+$", "")
			handle:close()

			-- Check if python_path is valid
			if python_path and python_path ~= "" then
				-- sørg for at reloader-prosesser arver riktig miljø
				local venv = python_path:gsub("/bin/python$", "")
				if venv and venv ~= "" then
					vim.env.VIRTUAL_ENV = venv
					vim.env.PATH = venv .. "/bin:" .. vim.env.PATH
				end
				dap_python.setup(python_path, { pythonPath = python_path })
			else
				-- Fallback to system python
				dap_python.setup("python3")
			end
			dap_python.test_runner = "pytest"

			-- Add Python attach configuration
			local dap = require("dap")
			table.insert(dap.configurations.python, {
				name = "Python Attach :5678",
				type = "python",
				request = "attach",
				connect = { host = "127.0.0.1", port = 5678 },
				justMyCode = false,
			})

			local opts = { noremap = true, silent = true }
			vim.keymap.set("n", "<leader>dn", dap_python.test_method, opts)
			vim.keymap.set("n", "<leader>df", dap_python.test_class, opts)
			vim.keymap.set("v", "<leader>ds", dap_python.debug_selection, opts)
		end,
	},
}
