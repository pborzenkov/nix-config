vim.api.nvim_set_keymap('n', '<leader>e', "<cmd>lua require('telescope.builtin').find_files()<cr>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>/', "<cmd>lua require('telescope.builtin').live_grep()<cr>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>s', "<cmd>lua require('telescope.builtin').grep_string()<cr>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>b', "<cmd>lua require('telescope.builtin').buffers()<cr>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>m', "<cmd>lua require('telescope.builtin').marks()<cr>", {noremap = true})

require('telescope').setup {
    defaults = {
        prompt_prefix = '>',

        winblend = 0,
        layout_config = {horizontal = {preview_cutoff = 120}},

        selection_strategy = 'reset',
        sorting_strategy = 'descending',
        scroll_strategy = 'cycle',
        color_devicons = true
    }
}
