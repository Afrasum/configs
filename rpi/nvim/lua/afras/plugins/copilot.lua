return {
	"github/copilot.vim",
	event = "InsertEnter",
	cmd = "Copilot",
	build = ":Copilot setup",
	config = function()
		vim.g.copilot_no_tab_map = true
		vim.g.copilot_assume_mapped = true

		vim.api.nvim_set_keymap(
			"i",
			"xx",
			'copilot#Accept("")',
			{ expr = true, silent = true, script = true, noremap = true }
		)
		-- ⌥-x : neste ord
		vim.keymap.set("i", "<A-x>", "<Plug>(copilot-accept-word)", { silent = true, noremap = true })

		-- ⌥⌃-x : første linje
		vim.keymap.set("i", "<C-x>", "<Plug>(copilot-accept-line)", { silent = true, noremap = true })

		vim.api.nvim_set_keymap("i", "<C-n>", "copilot#Next()", { expr = true, silent = true, noremap = true })
		vim.api.nvim_set_keymap("i", "<C-p>", "copilot#Previous()", { expr = true, silent = true, noremap = true })
	end,
}
