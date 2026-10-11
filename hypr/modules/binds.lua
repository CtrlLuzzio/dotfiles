-- https://wiki.hypr.land/Configuring/Basics/Binds/
local terminal = "foot"
local fileManager = "nautilus"
local ipc = "noctalia msg "
local menu = ipc .. " panel-toggle launcher"
local browser = "zen-browser"
local mainMod = "SUPER"
local secondaryMod = "ALT"
local smw = require("plugins.split-monitor-workspaces")

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(secondaryMod .. " + backslash", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. "+Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(secondaryMod .. "+ SHIFT + Return", hl.dsp.layout("togglesplit"))    -- dwindle only
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/.config/waybar/scripts/reboot.sh"))
hl.bind("Print", hl.dsp.exec_cmd("bash -c 'wayfreeze & PID=$!; sleep 0.1; AREA=$(slurp); [ -z \"$AREA\" ] && { kill $PID; exit 1; }; sleep 0.15;exec 3< <(grim -g \"$AREA\" -); kill $PID; satty --filename - <&3; exec 3<&-'"))
hl.bind(mainMod .. "+S", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("change-theme -m"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("change-wallpaper -m"))

hl.bind(secondaryMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(secondaryMod .. " + A", hl.dsp.window.fullscreen({ mode = 1, action = "toggle" }))

hl.bind(mainMod .. " + H",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }))

hl.bind(mainMod .. " +  SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. "+ N", hl.dsp.exec_cmd("python3 ~/.config/hypr/scripts/toggle-layout.py"))

for i = 1, 10 do
    local key = i % 10
    local n = tostring(i)
    hl.bind(mainMod .. " + " .. key, smw.workspace(n))
    hl.bind(secondaryMod .. " + " .. key, smw.move_to_workspace(n))
end

hl.bind(mainMod .. " + comma",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + period", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("CTRL + comma",  hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("CTRL + period", hl.dsp.window.move({ workspace = "e+1" }))

hl.bind(secondaryMod .. " + Z", hl.dsp.workspace.toggle_special("magic"))
hl.bind(secondaryMod .. " + SHIFT + Z", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"))
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind(mainMod .. "+SHIFT+comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher hold"))
