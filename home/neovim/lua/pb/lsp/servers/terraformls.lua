local M = {}

M.is_available = function()
    return vim.fn.executable("terraform-ls") ~= 0
end

M.config = {}

return M
