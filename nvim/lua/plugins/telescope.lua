return {
    'nvim-telescope/telescope.nvim', version = '*',
    dependencies = { 
	'nvim-lua/plenary.nvim',
	{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
	local telescope = require("telescope")
	local builtin = require('telescope.builtin')
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
	vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
	vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
	vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
	vim.keymap.set('n', '<leader>fz', builtin.current_buffer_fuzzy_find, { desc = 'Find in current buffer' })
	vim.keymap.set('n', '<leader>th', function ()
	    builtin.colorscheme({
		enable_preview = true,
		attach_mappings = function (prompt_bufnr, map)
		    actions.select_default:replace(function ()
		    	actions.close(prompt_bufnr)
			local selection = action_state.get_selected_entry()
			if selection then
			    local theme = selection.value
			    vim.cmd.colorscheme(theme)
			    local theme_cache = vim.fn.stdpath("data") .. "/theme_cache.txt"
			    local f = io.open(theme_cache, "w")
			    if f then
			    	f:write(theme)
				f:close()
			    end
			end
		    end)
		    return true
		end
	    })	
	end, { desc = "Theme Selector" })
    end
}
