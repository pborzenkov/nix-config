local M = {}

M.is_available = function()
    return vim.fn.executable("clangd") == 1
end

M.config = {}

return M
