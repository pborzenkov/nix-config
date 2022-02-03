local M = {}

function M.set(cap, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    local opts = {noremap = true, silent = true}

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

    if cap.definitionProvider then
        buf_set_keymap('n', '<c-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    end

    if cap.implementationProvider then
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    end

    if cap.referencesProvider then
        buf_set_keymap('n', 'gr', "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    end

    if cap.callHierarchyProvider then
        buf_set_keymap('n', 'gc', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>', opts)
    end

    if cap.documentSymbolProvider then
        buf_set_keymap('n', 'gd', "<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>", opts)
    end

    if cap.workspaceSymbolProvider then
        buf_set_keymap('n', 'gw', "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<CR>", opts)
    end

    if cap.codeActionProvider then
        buf_set_keymap('n', '<leader>fa', "<cmd>lua require('pb.lsp.telescope').lsp_code_actions()<CR>", opts)
    end

    buf_set_keymap('n', '[e', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']e', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)

    if cap.renameProvider then
        buf_set_keymap('n', '<leader>rr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    end

    if cap.documentFormattingProvider then
        vim.api.nvim_command('au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)')
    end

    buf_set_keymap('i', '<c-p>', '<plug>(completion_trigger)', {silent = true})
end

return M
