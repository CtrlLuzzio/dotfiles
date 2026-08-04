return {
    "neovim/nvim-lspconfig",
    dependencies = {
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"rafamadriz/friendly-snippets",
	"odoo/odoo-neovim",
    },
    config = function()
	local lspconfig_defaults = require("lspconfig").util.default_config
	lspconfig_defaults.capabilities = vim.tbl_deep_extend(
	    "force",
	    lspconfig_defaults.capabilities,
	    require("blink.cmp").get_lsp_capabilities()
	)

	vim.api.nvim_create_autocmd("LspAttach", {
	    callback = function(event)
		local opts = { buffer = event.buf }

		vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
	        vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
		vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
		vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
		vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
		vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
		vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
		vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
		vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
		vim.keymap.set({"n", "x"}, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
		vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)

	    end
	})

	require("mason").setup()
	require("mason-lspconfig").setup({
	    ensure_installed = {
		"lua_ls",
		"basedpyright",
		"ts_ls",
		"ruff",
		"ty",
		"yamlls",
		"somesass_ls",
	    },
	})

	vim.lsp.enable("lua_ls")
        vim.lsp.enable("basedpyright")
        vim.lsp.enable("ts_ls")
        vim.lsp.enable("ruff")
        vim.lsp.enable("ty")
	vim.lsp.enable("nil_ls")
	vim.lsp.enable("nixfmt")
	vim.lsp.enable("nixpkgs_fmt")
	vim.lsp.enable("yamlls")
	vim.lsp.enable("somesass_ls")
	vim.lsp.config("odoo_ls", {
	    cmd = {
		vim.env.HOME .. "/.local/share/nvim/odoo/odoo_ls_server",
	    },
	    filetypes = { "python", "xml" },
	    capabilities = require("blink.cmp").get_lsp_capabilities(),
	    root_markers = { "odools.toml", ".git" },
	})
	vim.lsp.enable("odoo_ls")
    end
}
