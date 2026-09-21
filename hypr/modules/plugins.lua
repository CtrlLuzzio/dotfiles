package.path = package.path .. ";./?.lua;./?/init.lua"
local smw = require("plugins.split-monitor-workspaces")

smw.setup({
    monitor_priority = { "HDMI-A-1", "DP-2" },
    enable_persistent_workspaces = false
})