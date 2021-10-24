local M = {}

local jump_with_telescope = function(title, result, opts)
	opts = opts or {}

	local items = {{
		tagname = vim.fn.expand('<cword>'),
		from = {vim.fn.bufnr('%'), vim.fn.line('.'), vim.fn.col('.'), 0},
	}}
	local winid = vim.fn.win_getid()

	require('telescope.pickers').new(opts, {
		prompt_title = title,
		finder = require('telescope.finders').new_table {
			results = vim.lsp.util.locations_to_items(result),
			entry_maker = opts.entry_maker or require('telescope.make_entry').gen_from_quickfix(opts),
		},
		previewer = require('telescope.config').values.qflist_previewer(opts),
		sorter = require('telescope.config').values.generic_sorter(opts),
		attach_mappings = function()
			require('telescope.actions').select_default:enhance({
				pre = function()
					vim.fn.settagstack(winid, {items=items}, 't')
				end
			})

			return true
		end
	}):find()
end

M.implementation = function(err, _, result)
	if err then
		print("ERROR: " .. err)
		return
	end

	if not result or vim.tbl_isempty(result) then
		return
	end

	if not vim.tbl_islist(result) then
		vim.lsp.util.jump_to_location(result)
	elseif vim.tbl_islist(result) and #result == 1 then
		vim.lsp.util.jump_to_location(result[1])
	else
		jump_with_telescope('LSP Implementation', result)
	end
end

M.references = function(err, _, result)
	if err then
		print("ERROR: " .. err)
		return
	end

	if not result or vim.tbl_isempty(result) then
		return
	end

	jump_with_telescope('LSP References', result)
end

M.incoming_calls = function(err, _, result)
	if err then
		print("ERROR: " .. err)
		return
	end

	if not result or vim.tbl_isempty(result) then
		return
	end

	local locations = {}
	for _, call_hierarchy_call in pairs(result) do
		local call_hierarchy_item = call_hierarchy_call.from
		for _, range in pairs(call_hierarchy_call.fromRanges) do
			table.insert(locations, {
				uri = call_hierarchy_item.uri,
				range = range,
			})
		end
	end

	if #locations == 1 then
		vim.lsp.util.jump_to_location(locations[1])
	else
		jump_with_telescope('LSP Incoming Calls', locations)
	end
end

return M
