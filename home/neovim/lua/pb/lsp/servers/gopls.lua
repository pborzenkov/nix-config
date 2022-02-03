local M = {}

M.is_available = function()
    return vim.fn.executable("gopls") == 1
end

M.config = {}

return M
