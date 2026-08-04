-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
hl.window_rule({
    match = { class = "^Xdg-desktop-portal-gtk$" },
    no_blur = true,
    no_shadow = true,
    border_size = 0
})
hl.window_rule({
    name = "keep-sf6-focused",
    match = { title = "Street Fighter 6" },
    idle_inhibit = "always",
    render_unfocused = true
})
