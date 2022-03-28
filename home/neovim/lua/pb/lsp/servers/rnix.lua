local M = {}

M.is_available = function()
return vim.fn.executable("rnix-lsp") ~= 0
end

M.config = {}

return M
