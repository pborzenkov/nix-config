local M = {}

M.is_available = function()
    return vim.fn.executable('rust-analyzer') ~= 0
end

M.config = {}

return M
