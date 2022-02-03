local util = require 'lspconfig.util'

local M = {}

M.is_available = function()
    return vim.fn.executable('efm-langserver') ~= 0
end

M.config = {
    init_options = {documentFormatting = true},
    filetypes = {"lua"},
    settings = {
        rootMarkers = {util.find_git_ancestor()},
        languages = {lua = {{formatCommand = "lua-format -i", formatStdin = true}}}
    }
}

return M
