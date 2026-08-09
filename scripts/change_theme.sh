#!/usr/bin/env bash

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
THEME_DIR=$CONF_DIR/themes
THEME=""
MENU_MODE=0

mkdir -p "$THEME_DIR"
mkdir -p "$CACHE_DIR"

while getopts "t:d:lmh" opt; do
    case $opt in
        t) THEME="$OPTARG" ;;
        d) THEME_DIR="$OPTARG" ;;
        m) MENU_MODE=1 ;;
        l)
            echo -e "${CYAN}Available themes in $THEME_DIR:${NC}"
            if [ -d "$THEME_DIR" ]; then
                find -L "$THEME_DIR/" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | grep -v '^\.' | sort
            else
                echo -e "${YELLOW}$THEME_DIR does not exist.${NC}"
            fi
            exit 0
            ;;
        h)
            echo -e "${GREEN}Script usage:${NC}"
            echo "  change-theme <theme name>       Applies the theme."
            echo "  change-theme -t <theme name>    Applies the theme."
            echo "  change-theme -m                 Opens Rofi to select a theme."
            echo "  change-theme -d <directory>     Use a custom theme directory ($THEME_DIR by default)."
            echo "  change-theme -l                 List available themes."
            echo "  change-theme -h                 Shows this message."
            echo "If run without arguments in terminal, it will use fzf for interactive selection."
            echo ""
            echo "Examples:"
            echo "  change-theme tokyo-night"
            echo "  change-theme -t rosepine"
            echo "  change-theme -d /custom/theme/dir catppuccin"
            echo "  change-theme -t gruvbox -d /custom/theme/dir"
            echo ""
            echo "This script only changes themes for:"
            echo "  Zed (Text Editor)"
            echo '  NvChad (Neovim "distro")'
            echo "  Foot (Terminal emulator)"
            echo "  Zellij (Terminal multiplexor)"
            echo "  Hyprland (Wayland Window Manager)"
            echo "  MangoWM (Wayland Window Manager)"
            echo "  Kvantum (Qt theme manager)"
            echo "  Fuzzel (App launcher and fuzzy finder for Wayland)"
            echo "  Rofi (App launcher and dmenu replacement)"
            echo ""
            echo "Theme configuration steps:"
            echo "  1-Create a theme folder in the theme directory."
            echo "  2-Add files for the mentioned apps. The files must be calles .<app> (ex: .zed)."
            echo "  3-File content depends on the specific app, check the existing themes for examples."
            exit 0
            ;;
        \?)
            echo -e "${YELLOW}Usage: $0 [-t theme] [-m] [-d /custom/theme/dir] [-l] [-h]${NC}"
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

if [ -z "$THEME" ] && [ -n "$1" ]; then
    THEME="$1"
fi

if [ -z "$THEME" ]; then
    if [ -z "$(find -L "$THEME_DIR/" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null | grep -v '^\.')" ]; then
        echo -e "${YELLOW}Error: No themes found in $THEME_DIR${NC}"
        exit 1
    fi
    if [ "$MENU_MODE" -eq 1 ]; then
        if command -v rofi >/dev/null 2>&1; then
            THEME=$(find -L "$THEME_DIR/" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | grep -v '^\.' | sort | rofi -dmenu -i -p "Select Theme:")
        else
            echo -e "${YELLOW}Error: Rofi not found. Please install rofi for menu mode.${NC}"
            exit 1
        fi
    else
        if command -v fzf >/dev/null 2>&1; then
            THEME=$(find -L "$THEME_DIR/" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | grep -v '^\.' | sort | fzf --prompt="Select Theme: ")
        else
            echo -e "${YELLOW}Error: You need to provide a theme as a parameter, or install fzf/rofi for interactive selection.${NC}"
            echo "Use 'change-theme -h' for more info."
            exit 1
        fi
    fi
fi

if [ -z "$THEME" ]; then
    echo -e "${YELLOW}No theme selected. Exiting...${NC}"
    exit 0
fi

if [ ! -d "$THEME_DIR/$THEME" ]; then
    echo -e "${YELLOW}Theme '${THEME}' does not exist in $THEME_DIR${NC}"
    exit 1
fi

STATE_FILE="$CACHE_DIR/.current_theme"
PREVIOUS_THEME=""

if [ -f "$STATE_FILE" ]; then
    PREVIOUS_THEME=$(cat "$STATE_FILE")
fi

if [ "$THEME" = "$PREVIOUS_THEME" ]; then
    echo -e "${YELLOW}-> Theme '$THEME' already selected. Omitting wallpaper change...${NC}"
else
    echo "$THEME" > "$STATE_FILE"
    WP_DIR="$THEME_DIR/$THEME/wallpapers"
    if [ -d "$WP_DIR" ]; then
        WP=$(find -L "$WP_DIR/" -mindepth 1 -maxdepth 1 -type f | grep -iE '\.(jpg|jpeg|png|gif|webp)$' | shuf -n 1)
        if [ -n "$WP" ]; then
            echo -e "${CYAN}-> Changing wallpaper...${NC}"
            change-wallpaper -i "$WP"
        fi
    fi
fi

check_installed() {
    local cmd="$1"
    local name="$2"

    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    else
        echo -e "${YELLOW}-> $name is not installed (or isn´t in PATH). Skipping...${NC}"
        return 1
    fi
}

check_nvim_distro() {
    local NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

    if ! command -v nvim >/dev/null 2>&1; then
        echo -e "${YELLOW}-> Neovim is not installed. Skipping...${NC}"
        return 1
    fi

    if [ -d "$NVIM_DIR" ]; then
        #NvChad
        if [ -f "$NVIM_DIR/lua/chadrc.lua" ] || grep -qi "nvchad" "$NVIM_DIR/init.lua" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

echo -e "${GREEN}Applying theme: $THEME${NC}\n"

if check_installed "zellij" "Zellij"; then
    if [ -f "$THEME_DIR/$THEME/.zellij" ]; then
        ZELLIJ=$(cat "$THEME_DIR/$THEME/.zellij")
        ZELLIJ_DIR=$CONF_DIR/zellij
        ZELLIJ_CONFIG=$ZELLIJ_DIR/config.kdl

        mkdir -p "$ZELLIJ_DIR"
        if [ -f "$ZELLIJ_CONFIG" ]; then
            if grep -q "theme " "$ZELLIJ_CONFIG"; then
                sed -i "s/theme \".*\"/$ZELLIJ/" "$ZELLIJ_CONFIG"
            else
                echo "theme \"$ZELLIJ\"" >> "$ZELLIJ_CONFIG"
            fi
        else
            echo "theme "$ZELLIJ"" >> $ZELLIJ_CONFIG
        fi
        echo -e "${CYAN}-> Updated Zellij${NC}"
    fi
fi
if check_nvim_distro; then
    if [ -f "$THEME_DIR/$THEME/.nvchad" ]; then
        NVCHAD=$(cat "$THEME_DIR/$THEME/.nvchad")
        NVIM_DIR="$CONF_DIR/nvim"
        CHADRC_DIR="$NVIM_DIR/lua"
        CHADRC_CONFIG="$CHADRC_DIR/chadrc.lua"
        if [ -d "$NVIM_DIR" ]; then
            mkdir -p "$CHADRC_DIR"
            if [ -f "$CHADRC_CONFIG" ]; then
                sed -i "s/theme = \".*\"/$NVCHAD/" "$CHADRC_CONFIG"
            echo -e "${CYAN}-> Updated NvChad${NC}"
            fi
        fi
    fi
else
    echo -e "${YELLOW}-> Didn't found a known Neovim distro, Neovim theme not updated${NC}"
fi
if check_installed "foot" "Foot Terminal"; then
    if [ -f "$THEME_DIR/$THEME/.foot-colors" ] || [ -f "$THEME_DIR/$THEME/.foot-theme" ]; then
        FOOT_DIR="$CONF_DIR/foot"
        FOOT_THEME_DIR="$FOOT_DIR/themes"
        FOOT_CONFIG="$FOOT_DIR/foot.ini"

        mkdir -p "$FOOT_THEME_DIR"

        if [ -f "$THEME_DIR/$THEME/.foot-colors" ]; then
            cp "$THEME_DIR/$THEME/.foot-colors" "$FOOT_DIR/colors.ini"
        fi

        if [ -f "$THEME_DIR/$THEME/.foot-theme" ]; then
            cp "$THEME_DIR/$THEME/.foot-theme" "$FOOT_THEME_DIR/${THEME}.ini"
        fi

        if [ -f "$FOOT_CONFIG" ]; then
            if ! grep -q "include=$FOOT_DIR/colors.ini" "$FOOT_CONFIG"; then
                echo "include=$FOOT_DIR/colors.ini" >> "$FOOT_CONFIG"
            fi
        else
            echo "include=$FOOT_DIR/colors.ini" >> "$FOOT_CONFIG"
        fi
        echo -e "${CYAN}-> Updated Foot${NC}"
    else
        echo -e "${YELLOW}-> Missing Foot files in theme. Skipping...${NC}"
    fi
fi
if check_installed "zeditor" "Zed" || check_installed "zed" "Zed"; then
    if [ -f "$THEME_DIR/$THEME/.zed" ]; then
        ZED="$THEME_DIR/$THEME/.zed"
        ZED_DIR=$CONF_DIR/zed
        ZED_CONFIG=$ZED_DIR/settings.json

        LIGHT=$(grep '"light":' "$ZED" | cut -d'"' -f4)
        DARK=$(grep '"dark":' "$ZED" | cut -d'"' -f4)

        mkdir -p "$ZED_DIR"

        if [ -f "$ZED_CONFIG" ]; then
            sed -i '/"theme":[[:space:]]*{/,/}/ {
                s/\("light":[[:space:]]*\)".*"/\1"'"$LIGHT"'"/
                s/\("dark":[[:space:]]*\)".*"/\1"'"$DARK"'"/
            }' $ZED_CONFIG
        else
            echo '{' > "$ZED_CONFIG"
            cat $ZED >> $ZED_CONFIG
            echo '}' >> "$ZED_CONFIG"
        fi
        echo -e "${CYAN}-> Updated Zed${NC}"
    fi
fi
if check_installed "kvantummanager" "Kvantum"; then
    if [ -f "$THEME_DIR/$THEME/.kvantum" ]; then
        KVANTUM_BASE=$(cat "$THEME_DIR/$THEME/.kvantum" | tr -d '\r\n')
        KVANTUM_DIRS=(
            "$HOME/.config/Kvantum"
            "/run/current-system/sw/share/Kvantum"
            "$HOME/.nix-profile/share/Kvantum"
            "/usr/share/Kvantum"
        )
        KVANTUM_MATCH=""
        for dir in "${KVANTUM_DIRS[@]}"; do
            if [ -d "$dir" ]; then
                MATCH=$(find "$dir" -mindepth 1 -maxdepth 1 -type d -iname "*${KVANTUM_BASE}*" -exec basename {} \; 2>/dev/null | head -n 1)
                if [ -n "$MATCH" ]; then
                    KVANTUM_MATCH="$MATCH"
                    break
                fi
            fi
        done
        if [ -n "$KVANTUM_MATCH" ]; then
            kvantummanager --set "$KVANTUM_MATCH" > /dev/null 2>&1
            echo -e "${CYAN}-> Updated Kvantum ($KVANTUM_MATCH)${NC}"
        else
            echo -e "${YELLOW}Please install a Kvantum theme matching '$KVANTUM_BASE' first.${NC}"
        fi
    fi
fi
if check_installed "fuzzel" "Fuzzel"; then
    if [ -f "$THEME_DIR/$THEME/.fuzzel" ]; then
        FUZZEL=$(cat "$THEME_DIR/$THEME/.fuzzel")
        FUZZEL_DIR=$CONF_DIR/fuzzel
        FUZZEL_CONFIG=$FUZZEL_DIR/fuzzel.ini
        mkdir -p "$FUZZEL_DIR"
        cp "$THEME_DIR/$THEME/.fuzzel" $FUZZEL_DIR/theme.ini
        if [ -f "$FUZZEL_CONFIG" ]; then
            if ! grep -q "include=$FUZZEL_DIR/theme.ini" "$FUZZEL_CONFIG"; then
            echo "include=$FUZZEL_DIR/theme.ini" >> $FUZZEL_CONFIG
            fi
        else
            echo "include=$FUZZEL_DIR/theme.ini" >> $FUZZEL_CONFIG
        fi
        echo -e "${CYAN}-> Updated Fuzzel${NC}"
    fi
fi
if check_installed "hyprctl" "Hyprland"; then
    if [ -f "$THEME_DIR/$THEME/.hypr-colors" ] || [ -f "$THEME_DIR/$THEME/.hypr-theme" ]; then
        HYPR_DIR="$CONF_DIR/hypr/modules"
        HYPR_THEME_DIR="$HYPR_DIR/themes"
        mkdir -p "$HYPR_THEME_DIR"

        if [ -f "$THEME_DIR/$THEME/.hypr-colors" ]; then
            cp "$THEME_DIR/$THEME/.hypr-colors" "$HYPR_DIR/colors.lua"
        fi

        if [ -f "$THEME_DIR/$THEME/.hypr-theme" ]; then
            cp "$THEME_DIR/$THEME/.hypr-theme" "$HYPR_THEME_DIR/${THEME}.lua"
        fi

        hyprctl reload &

        echo -e "${CYAN}-> Updated Hyprland${NC}"
    else
        echo -e "${YELLOW}-> Missing Hyprland files in theme. Skipping...${NC}"
    fi
fi

if check_installed "mmsg" "MangoWM"; then
    if [ -f "$THEME_DIR/$THEME/.mango-colors" ] || [ -f "$THEME_DIR/$THEME/.mango-theme" ]; then
        MANGO_DIR="$CONF_DIR/mango/modules"
        MANGO_THEME_DIR="$MANGO_DIR/themes"
        mkdir -p "$MANGO_THEME_DIR"

        if [ -f "$THEME_DIR/$THEME/.mango-colors" ]; then
            cp "$THEME_DIR/$THEME/.mango-colors" "$MANGO_DIR/colors.conf"
        fi

        if [ -f "$THEME_DIR/$THEME/.mango-theme" ]; then
            cp "$THEME_DIR/$THEME/.mango-theme" "$MANGO_THEME_DIR/${THEME}.conf"
        fi

        mmsg dispatch reload_config > /dev/null 2>&1
        echo -e "${CYAN}-> Updated MangoWM${NC}"
    else
        echo -e "${YELLOW}-> Missing MangoWM files in theme. Skipping...${NC}"
    fi
fi
if check_installed "waybar" "Waybar"; then
    if [ -f "$THEME_DIR/$THEME/.import-css" ] || [ -f "$THEME_DIR/$THEME/.gtk-css" ]; then
        WAYBAR_DIR="$CONF_DIR/waybar"
        WAYBAR_THEME_DIR="$WAYBAR_DIR/themes"
        mkdir -p "$WAYBAR_THEME_DIR"

        if [ -f "$THEME_DIR/$THEME/.import-css" ]; then
            cp "$THEME_DIR/$THEME/.import-css" "$WAYBAR_DIR/colors.css"
        fi

        if [ -f "$THEME_DIR/$THEME/.gtk-css" ]; then
            cp "$THEME_DIR/$THEME/.gtk-css" "$WAYBAR_THEME_DIR/${THEME}.css"
        fi

        pkill -SIGUSR2 waybar
        echo -e "${CYAN}-> Updated Waybar${NC}"
    else
        echo -e "${YELLOW}-> Missing Waybar CSS files in theme. Skipping...${NC}"
    fi
fi

if check_installed "swaync-client" "SwayNC"; then
    if [ -f "$THEME_DIR/$THEME/.import-css" ] || [ -f "$THEME_DIR/$THEME/.css" ]; then
        SWAYNC_DIR="$CONF_DIR/swaync"
        SWAYNC_THEME_DIR="$SWAYNC_DIR/themes"
        mkdir -p "$SWAYNC_THEME_DIR"

        if [ -f "$THEME_DIR/$THEME/.import-css" ]; then
            cp "$THEME_DIR/$THEME/.import-css" "$SWAYNC_DIR/colors.css"
        fi

        if [ -f "$THEME_DIR/$THEME/.css" ]; then
            cp "$THEME_DIR/$THEME/.css" "$SWAYNC_THEME_DIR/${THEME}.css"
        fi

        swaync-client -rs > /dev/null 2>&1
        echo -e "${CYAN}-> Updated SwayNC${NC}"
    else
        echo -e "${YELLOW}-> Missing SwayNC CSS files in theme. Skipping...${NC}"
    fi
fi

if check_installed "rofi" "Rofi"; then
    if [ -f "$THEME_DIR/$THEME/.import-rasi" ] || [ -f "$THEME_DIR/$THEME/.rasi" ]; then
        ROFI_DIR="$CONF_DIR/rofi"
        ROFI_THEME_DIR="$ROFI_DIR/themes"
        mkdir -p "$ROFI_THEME_DIR"

        if [ -f "$THEME_DIR/$THEME/.import-rasi" ]; then
            cp "$THEME_DIR/$THEME/.import-rasi" "$ROFI_DIR/colors.rasi"
        fi

        if [ -f "$THEME_DIR/$THEME/.rasi" ]; then
            cp "$THEME_DIR/$THEME/.rasi" "$ROFI_THEME_DIR/${THEME}.rasi"
        fi

        echo -e "${CYAN}-> Updated Rofi${NC}"
    else
        echo -e "${YELLOW}-> Missing Rofi files in theme. Skipping...${NC}"
    fi
fi
if [ "$THEME" = "material-you" ]; then
    if check_installed "matugen" "Matugen"; then
        if [ -f "$CACHE_DIR/.current_wallpaper" ]; then
            CURRENT_WP=$(cat "$CACHE_DIR/.current_wallpaper")
            echo -e "${CYAN}-> Applying colors from current wallpaper...${NC}"
            matugen image "$CURRENT_WP" -b wal --source-color-index 0 > /dev/null 2>&1
        else
            echo -e "${YELLOW}-> No current wallpaper found. Please set a wallpaper first with the change_wallpaper script.${NC}"
        fi
    else
        echo -e "${YELLOW}-> matugen is not installed. Skipping...${NC}"
    fi
fi
echo -e "${GREEN}Done!${NC}"
