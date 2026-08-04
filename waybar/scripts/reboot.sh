#!/usr/bin/env bash
pkill waybar
pkill swaync

sleep 1

if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    waybar -c ~/.config/waybar/config-ext.jsonc &
else
    waybar -c ~/.config/waybar/config-ext.jsonc &
fi

swaync &
