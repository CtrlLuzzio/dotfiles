return {
  "folke/which-key.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-mini/mini.icons",
  },
  event = "VeryLazy",
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
