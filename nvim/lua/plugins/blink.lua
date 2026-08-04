return {
    "saghen/blink.cmp",
    dependencies = {
	"saghen/blink.lib",
        "rafamadriz/friendly-snippets",
    },
    build = function()
	require("blink.cmp").build():pwait()
    end,

    ---@module "blink.cmp"
    ---@type blink.cmp.config
    opts = {
	keymap = {
	    preset = "default"
	},
	completion = {
	    documentation = { auto_show = false }
	},
	sources = {
	    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
	    providers = {
		lazydev = {
		    name = "LazyDev",
		    module = "lazydev.integrations.blink",
		    score_offset = 100,
		},
	    },
	},
	fuzzy = {
	    implementation = "rust"
	},
    },
}
