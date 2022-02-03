local themes = require('telescope.themes')

local M = {}

function M.lsp_code_actions()
    local opts = themes.get_dropdown {border = true, previewer = false, path_display = {"shorten"}}

    require('telescope.builtin').lsp_code_actions(opts)
end

return M
