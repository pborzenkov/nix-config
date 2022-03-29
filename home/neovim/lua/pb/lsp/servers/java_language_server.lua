local M = {}

M.is_available = function()
    return vim.fn.executable("java-language-server") == 1
end

M.config = {cmd = {"java-language-server"}}

return M
