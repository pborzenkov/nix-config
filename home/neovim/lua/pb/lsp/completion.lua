vim.api.nvim_set_option('completeopt', 'menuone,noinsert,noselect')
vim.api.nvim_set_option('shortmess', vim.api.nvim_get_option('shortmess') .. 'c')

vim.api.nvim_set_var('completion_matching_smart_case', 1)

vim.api.nvim_set_var('completion_enable_auto_popup', 0)
vim.api.nvim_set_var('completion_confirm_key', "\\<C-y>")
