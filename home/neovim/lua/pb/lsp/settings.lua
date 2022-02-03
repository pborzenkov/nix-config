local lsp = require('lspconfig')
local completion = require('completion')
local remaps = require('pb.lsp.remaps')

local function on_attach(client, bufnr)
    remaps.set(client.server_capabilities, bufnr)
    completion.on_attach(client, bufnr)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    virtual_text = {spacing = 0, prefix = " ■ "},
    signs = true,
    update_in_insert = false
})

vim.lsp.handlers["textDocument/implementation"] = require('pb.lsp.handlers').implementation
vim.lsp.handlers["textDocument/references"] = require('pb.lsp.handlers').references
vim.lsp.handlers["callHierarchy/incomingCalls"] = require('pb.lsp.handlers').incoming_calls

local default_lsp_config = {on_attach = on_attach}

local servers = {}

for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath('config') .. '/lua/pb/lsp/servers', [[v:val =~ '\.lua$']])) do
    local srvname = file:gsub('%.lua$', '')
    servers[srvname] = require('pb.lsp.servers.' .. srvname)
end

for srvname, srv in pairs(servers) do
    if srv.is_available() then
        lsp[srvname].setup(vim.tbl_deep_extend("force", default_lsp_config, srv.config))
    end
end
