vim.api.nvim_set_option('wildmode', 'longest,full')
vim.api.nvim_set_option('wildoptions', 'pum')

vim.api.nvim_set_option('cmdheight', 1)
vim.api.nvim_set_option('incsearch', true)
vim.api.nvim_set_option('ignorecase', true)
vim.api.nvim_set_option('smartcase', true)

vim.api.nvim_set_option('showmatch', true)

vim.api.nvim_set_option('autowrite', true)
vim.api.nvim_set_option('autoread', true)
vim.api.nvim_set_option('hidden', true)

vim.api.nvim_win_set_option(0, 'number', true)
vim.api.nvim_win_set_option(0, 'relativenumber', true)

vim.api.nvim_buf_set_option(0, 'textwidth', 120)

vim.api.nvim_buf_set_option(0, 'swapfile', false)

vim.api.nvim_win_set_option(0, 'breakindent', true)
vim.api.nvim_set_option('showbreak', '   ')
vim.api.nvim_win_set_option(0, 'linebreak', true)

vim.api.nvim_set_option('belloff', 'all')

vim.api.nvim_set_option('scrolloff', 5)

vim.api.nvim_set_option('updatetime', 1000)

vim.api.nvim_win_set_option(0, 'signcolumn', 'yes:1')

vim.api.nvim_set_keymap('n', '<c-\\>', "<cmd>b#<cr>", {noremap = true})
vim.api.nvim_set_keymap('i', '<c-\\>', "<esc><cmd>b#<cr>", {noremap = true})

vim.api.nvim_set_keymap('n', '<c-n>', "<cmd>cnext<cr>", {noremap = true})
vim.api.nvim_set_keymap('n', '<c-p>', "<cmd>cprev<cr>", {noremap = true})
