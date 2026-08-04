return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
	view = {
	    width = 30,
	    side = "left",
	},
	actions = {
	    open_file = {
		quit_on_open = false,
	    }
	},
	filters = {
	    git_ignored = false,
	    dotfiles = false,
	}
    })
  end,
}
