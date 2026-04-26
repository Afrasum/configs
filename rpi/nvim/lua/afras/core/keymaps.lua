-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- Custom mapping
--
--
--
keymap.set("n", "<leader>z", "<cmd>set wrap! linebreak!<CR>")
keymap.set("n", "<leader><leader>", "<C-^>", { noremap = true })

keymap.set("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true })
keymap.set("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true })
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

local opts = { noremap = true, silent = true }

-- Normalmodus
keymap.set("n", "d", '"_d', opts) -- d som vanlig delete-operator, men uten yanking
keymap.set("n", "c", '"_c', opts) -- c som vanlig change-operator, men uten yanking
keymap.set("n", "s", "d", opts) -- s = delete OG yank (som original d)
keymap.set("n", "x", '"_x', opts) -- x (delete char) uten yanking

-- Visuell modus
keymap.set("v", "d", '"_d', opts)
keymap.set("v", "c", '"_c', opts)
keymap.set("v", "s", "d", opts) -- s = delete OG yank (som original d)
keymap.set("v", "x", '"_x', opts)

-- Insertmodus
keymap.set(
	"i",
	"<A-BS>",
	"<C-w>",
	{ noremap = true, silent = true, desc = "Delete word before cursor (Alt + Backspace)" }
)
