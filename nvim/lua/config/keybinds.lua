vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle Explorer" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to the down window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to the up window" })
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { silent = true, desc = "Go to the next tab" })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { silent = true, desc = "Go to the previous tab" })
vim.keymap.set("n", "<leader>x", ":bd<CR>", { silent = true, desc = "Close tab" })
