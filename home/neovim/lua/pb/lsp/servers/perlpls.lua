local M = {}

M.is_available = function()
    return vim.fn.executable("pls") == 1
end

M.config = {settings = {perl = {perlcritic = {enabled = true}}}}

return M
