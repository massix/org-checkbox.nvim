local M = {}

local inspect_node = function()
	local current_node = vim.treesitter.get_node()
	local bullet_node = nil
	local is_list = false
	local has_checkbox = false

	if current_node then
		local listitem_node = nil

		if current_node:type() == "listitem" then
			listitem_node = current_node
		else
			--- @type TSNode|nil
			local parent = current_node:parent()

			while parent ~= nil do
				if parent:type() == "listitem" then
					listitem_node = parent
					break
				end

				parent = parent:parent()
			end
		end

		if listitem_node ~= nil then
			is_list = true

			-- Get all children of the listitem_node
			local children_iterator = listitem_node:iter_children()
			local current_child = children_iterator()
			while current_child ~= nil do
				if current_child:type() == "checkbox" then
					has_checkbox = true
				elseif current_child:type() == "bullet" then
					bullet_node = current_child
				end

				current_child = children_iterator()
			end
		end
	end

	return is_list, has_checkbox, bullet_node
end

M.setup = function(opts)
	local cb_group = vim.api.nvim_create_augroup("OrgCheckbox", { clear = true })
	local lhs = (opts and opts.lhs) or "<leader>oC"

	vim.api.nvim_create_autocmd({ "Filetype" }, {
		pattern = { "org" },
		group = cb_group,
		callback = function()
			vim.api.nvim_buf_set_keymap(
				0,
				"n",
				lhs,
				'<CMD>lua require("orgcheckbox").toggle_checkbox()<CR>',
				{ desc = "org toggle checkbox", silent = true }
			)
		end,
	})
end

M.toggle_checkbox = function()
	local is_list, has_checkbox, bullet_node = inspect_node()
	local current_position = vim.api.nvim_win_get_cursor(0)

	if bullet_node then
		local bullet_row, bullet_col, _ = bullet_node:start()

		vim.api.nvim_win_set_cursor(0, { bullet_row + 1, bullet_col })

		if is_list and has_checkbox then
			vim.cmd("normal! ^t[4x")

			-- Move the cursor if we are on the same line than the bullet
			-- and we are after the checkbox
			if current_position[1] == bullet_row + 1 and current_position[2] > 4 then
				current_position[2] = current_position[2]
			end
		elseif is_list then
			vim.cmd("normal! ^a [ ]")

			-- Move the cursor if we are on the same line than the bullet
			if current_position[1] == bullet_row + 1 then
				current_position[2] = current_position[2] + 4
			end
		end
	end

	vim.api.nvim_win_set_cursor(0, current_position)
end

return M
