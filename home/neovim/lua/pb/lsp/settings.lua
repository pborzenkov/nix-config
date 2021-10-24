local lsp = require('lspconfig')
local completion = require('completion')
local remaps = require('pb.lsp.remaps')

local function on_attach(client, bufnr)
	remaps.set(client.server_capabilities, bufnr)
	completion.on_attach(client, bufnr)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics, {
		underline = true,
		virtual_text = {
			spacing = 0,
			prefix = " ■ ",
		},
		signs = true,
		update_in_insert = false,
	}
)

vim.lsp.handlers["textDocument/implementation"] = require('pb.lsp.handlers').implementation
vim.lsp.handlers["textDocument/references"] = require('pb.lsp.handlers').references
vim.lsp.handlers["callHierarchy/incomingCalls"] = require('pb.lsp.handlers').incoming_calls

local default_lsp_config = {
	on_attach = on_attach,
}

local servers = {
	gopls = require('pb.lsp.servers.gopls'),
	rnix = require('pb.lsp.servers.rnix'),
	rust_analyzer = require('pb.lsp.servers.rust_analyzer'),
	sumneko_lua = require('pb.lsp.servers.sumneko_lua'),
	terraformls = require('pb.lsp.servers.terraformls'),
}

for server, config in pairs(servers) do
	lsp[server].setup(vim.tbl_deep_extend("force", default_lsp_config, config))
end
