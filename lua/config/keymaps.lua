-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
local map = vim.keymap.set
local wk = require("which-key")

map("n", "<C-w>", "<cmd>w<cr><esc>", { desc = "Save file" })

wk.register({
  b = {
    name = "Buffer",
    b = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
  },
}, { prefix = "<leader>" })
