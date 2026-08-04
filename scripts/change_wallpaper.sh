#!/usr/bin/env bash

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
THEME_DIR="$CONF_DIR/themes"
ALL_WP_DIR="$CONF_DIR/wallpapers"
WALLPAPER=""
MENU_MODE=0
CUSTOM_DIR=""

mkdir -p "$ALL_WP_DIR"

while getopts "i:d:lmh" opt; do
    case $opt in
        i) WALLPAPER="$OPTARG" ;;
        d) CUSTOM_DIR="$OPTARG" ;;
        m) MENU_MODE=1 ;;
        l)
            echo -e "${CYAN}Global wallpapers in $ALL_WP_DIR:${NC}"
            ls -1 "$ALL_WP_DIR"
            exit 0
            ;;
        h)
            echo -e "${GREEN}Script usage:${NC}"
            echo "  change-wallpaper -i <file>      Applies the specific wallpaper."
            echo "  change-wallpaper -m             Opens Rofi to select a wallpaper."
            echo "  change-wallpaper -d <dir>       Use a custom directory to search for wallpapers."
            echo "  change-wallpaper -l             List all wallpapers."
            echo "  change-wallpaper -h             Shows this message."
            echo ""
            echo "If run without arguments, it will use fzf for interactive selection."
            exit 0
            ;;
        \?)
            echo -e "${YELLOW}Usage: $0 [-i file] [-d dir] [-m] [-l] [-h]${NC}"
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

CURRENT_THEME=""
if [ -f "$CACHE_DIR/.current_theme" ]; then
    CURRENT_THEME=$(cat "$CACHE_DIR/.current_theme")
fi

SEARCH_DIR="$ALL_WP_DIR"
SHOW_ALL_OPTION=0

if [ -n "$CUSTOM_DIR" ]; then
    SEARCH_DIR="$CUSTOM_DIR"
elif [ -n "$CURRENT_THEME" ] && [ -d "$THEME_DIR/$CURRENT_THEME/wallpapers" ]; then
    SEARCH_DIR="$THEME_DIR/$CURRENT_THEME/wallpapers"
    SHOW_ALL_OPTION=1
fi

select_wallpaper() {
    local current_dir="$1"
    local show_all="$2"
    local options=""
    local selection=""

    options=$(find -L "$current_dir" -maxdepth 1 -type f -o -type l | grep -iE '\.(jpg|jpeg|png|gif|webp)$' | awk -F/ '{print $NF}')

    if [ -z "$options" ]; then
        echo -e "${YELLOW}No images found in $current_dir${NC}" >&2
        return 1
    fi

    if [ "$show_all" -eq 1 ]; then
        options="[+] Show all wallpapers\n$options"
    fi

    if [ "$MENU_MODE" -eq 1 ]; then
        if command -v rofi >/dev/null 2>&1; then
            selection=$((
                if [ "$show_all" -eq 1 ]; then
                    printf "[+] Show all wallpapers\0icon\037folder\n"
                fi
                find -L "$current_dir" -maxdepth 1 -type f -o -type l | grep -iE '\.(jpg|jpeg|png|gif|webp)$' | while read -r file; do
                    printf "%s\0icon\037%s\n" "$(basename "$file")" "$file"
                done
            ) | rofi -dmenu -i -p "Select Wallpaper:" -theme ~/.config/rofi/extra-layouts/wallpaper-selector.rasi)
        else
            echo -e "${YELLOW}Error: Rofi not found.${NC}" >&2
            exit 1
        fi
    else
        if [ "$show_all" -eq 1 ]; then
            options="[+] Show all wallpapers\n$options"
        fi

        if command -v fzf >/dev/null 2>&1; then
            selection=$(echo -e "$options" | fzf --prompt="Select Wallpaper: ")
        else
            echo -e "${YELLOW}Error: fzf/rofi not installed.${NC}" >&2
            exit 1
        fi
    fi

    echo "$selection"
}

if [ -z "$WALLPAPER" ]; then
    SELECTED_FILE=$(select_wallpaper "$SEARCH_DIR" "$SHOW_ALL_OPTION")

    if [ -z "$SELECTED_FILE" ]; then
        echo -e "${YELLOW}No wallpaper selected. Exiting...${NC}"
        exit 0
    fi

    if [ "$SELECTED_FILE" = "[+] Show all wallpapers" ]; then
        SEARCH_DIR="$ALL_WP_DIR"
        SELECTED_FILE=$(select_wallpaper "$SEARCH_DIR" 0)

        if [ -z "$SELECTED_FILE" ]; then
            echo -e "${YELLOW}No wallpaper selected. Exiting...${NC}"
            exit 0
        fi
    fi

    WALLPAPER="$SEARCH_DIR/$SELECTED_FILE"
fi

if [ ! -f "$WALLPAPER" ]; then
    echo -e "${YELLOW}Wallpaper '$WALLPAPER' does not exist.${NC}"
    exit 1
fi

echo -e "${GREEN}Applying wallpaper: $(basename "$WALLPAPER")${NC}"

if command -v awww >/dev/null 2>&1; then
    if ! awww query >/dev/null 2>&1; then
        echo -e "${CYAN}-> Starting awww daemon...${NC}"
        awww-daemon &
        sleep 1
    fi

    awww img "$WALLPAPER" --transition-type wipe --transition-fps 75 --transition-pos 0.5,0.5 --transition-step 255
    echo -e "${CYAN}-> Wallpaper updated via awww.${NC}"
else
    echo -e "${YELLOW}Error: awww is not installed or not in PATH.${NC}"
    exit 1
fi

echo "$WALLPAPER" > "$CACHE_DIR/.current_wallpaper"

if [ "$CURRENT_THEME" = "material-you" ]; then
    if command -v matugen >/dev/null 2>&1; then
        echo -e "${CYAN}-> Generating colors..${NC}"
        matugen image "$WALLPAPER" -b wal --source-color-index 0 > /dev/null 2>&1
    else
        echo -e "${YELLOW}-> matugen is not installed. Skipping...${NC}"
    fi
fi

echo -e "${GREEN}Done!${NC}"
