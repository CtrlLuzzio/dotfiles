require("config.options")
require("config.keybinds")
require("config.lazy")

local theme_cache = vim.fn.stdpath("data") .. "/theme_cache.txt"
local f = io.open(theme_cache, "r")
local theme = "catppuccin"

if f then
    local saved_theme = f:read("*a"):gsub("%s+", "")
    f:close()
    if saved_theme ~= "" then
    	theme = saved_theme
    end
end

pcall(vim.cmd.colorscheme, theme)
