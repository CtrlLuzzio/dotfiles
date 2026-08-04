#!/usr/bin/env bash

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN_DIR="$HOME/.local/bin"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}Starting dotfiles installation...${NC}"
echo -e "${CYAN}-> Checking and creating base directories...${NC}"
mkdir -p "$CONF_DIR"
mkdir -p "$BIN_DIR"

echo -e "${CYAN}-> Creating symlinks in $CONF_DIR...${NC}"

IGNORE_LIST=("shell" "scripts" "install-dotfiles.sh" "README.md" "LICENSE")

is_ignored() {
    local item="$1"
    for ignore in "${IGNORE_LIST[@]}"; do
        if [[ "$ignore" == "$item" ]]; then
            return 0
        fi
    done
    return 1
}

for item_path in "$DOTFILES_DIR"/*; do
    dot=$(basename "$item_path")
    if is_ignored "$dot" || [[ "$dot" == .* ]]; then
        continue
    fi
    if [ -d "$item_path" ]; then
        if [ -d "$CONF_DIR/$dot" ] && [ ! -L "$CONF_DIR/$dot" ]; then
            echo -e "${YELLOW}-> Backing up existing $CONF_DIR/$dot to ${dot}.bak...${NC}"
            mv "$CONF_DIR/$dot" "$CONF_DIR/${dot}.bak"
        fi
        
        rm -rf "$CONF_DIR/$dot" 2>/dev/null
        ln -sfn "$item_path" "$CONF_DIR/$dot"
        echo -e "${GREEN}-> Linked: $dot${NC}"
    fi
done

echo -e "${CYAN}-> Linking Shell configurations to $HOME...${NC}"

SHELL_FILES=(
    "shell/zsh/.zshrc:$HOME/.zshrc"
    "shell/zsh/.p10k.zsh:$HOME/.p10k.zsh"
    "shell/zsh/.zprofile:$HOME/.zprofile"
    "shell/bash/.bashrc:$HOME/.bashrc"
    "shell/bash/.bash_logout:$HOME/.bash_logout"
    "shell/bash/.bash_profile:$HOME/.bash_profile"
    "shell/.profile:$HOME/.profile"
)

for entry in "${SHELL_FILES[@]}"; do
    src="${entry%%:*}"
    dest="${entry##*:}"
    
    if [ -f "$DOTFILES_DIR/$src" ]; then
        if [ -f "$dest" ] && [ ! -L "$dest" ]; then
            echo -e "${YELLOW}-> Backing up existing $(basename "$dest") to $(basename "$dest").bak...${NC}"
            mv "$dest" "$dest.bak"
        fi
        
        rm -f "$dest" 2>/dev/null
        ln -sf "$DOTFILES_DIR/$src" "$dest"
        echo -e "${GREEN}-> Linked: $(basename "$dest")${NC}"
    else
        echo -e "${YELLOW}-> Warning: '$src' file not found in $DOTFILES_DIR. Skipping...${NC}"
    fi
done

echo -e "${CYAN}-> Setting up custom scripts in $BIN_DIR...${NC}"

SCRIPTS_DIR="$DOTFILES_DIR/scripts"

chmod +x "$SCRIPTS_DIR/change_theme.sh" 2>/dev/null
chmod +x "$SCRIPTS_DIR/change_wallpaper.sh" 2>/dev/null

ln -sf "$SCRIPTS_DIR/change_theme.sh" "$BIN_DIR/change-theme"
ln -sf "$SCRIPTS_DIR/change_wallpaper.sh" "$BIN_DIR/change-wallpaper"
echo -e "${GREEN}-> Scripts linked: change-theme, change-wallpaper${NC}"

echo -e "${GREEN}Installation complete!${NC}"