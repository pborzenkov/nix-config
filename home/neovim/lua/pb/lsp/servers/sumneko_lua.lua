local M = {}

M.is_available = function()
    return vim.fn.executable('lua-language-server') ~= 0
end

M.config = {
    settings = {
        Lua = {
            runtime = {version = "LuaJIT", path = vim.split(package.path, ";")},
            diagnostics = {globals = {"vim", "use"}},
            workspace = {
                library = {[vim.fn.expand("$VIMRUNTIME/lua")] = true, [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true}
            }
        }
    }
}

return M
