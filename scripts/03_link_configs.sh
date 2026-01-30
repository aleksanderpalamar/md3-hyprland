#!/bin/bash
# License: GPLv3
# Main Installer for MD3-Hyprland
# Author: Aleksander Palamar

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PROJECT_DIR=$(pwd) # Assuming script is run from project root, will adjust in main install
CONFIG_SRC="$PROJECT_DIR/config"
TARGET_DIR="$HOME/.config"

echo -e "${BLUE}[*] Linking configurations...${NC}"

# List of configs to manage
CONFIGS=("hypr" "waybar" "rofi" "kitty" "swaync" "matugen")

for cfg in "${CONFIGS[@]}"; do
    TARGET="$TARGET_DIR/$cfg"
    SOURCE="$CONFIG_SRC/$cfg"

    # Backup if exists and is not already a link to our source
    if [ -d "$TARGET" ] || [ -f "$TARGET" ]; then
        if [ -L "$TARGET" ] && [ "$(readlink -f "$TARGET")" == "$SOURCE" ]; then
            echo -e "${GREEN}[+] $cfg is already correctly linked.${NC}"
            continue
        fi

        BACKUP_NAME="${cfg}.backup_${TIMESTAMP}"
        echo -e "${YELLOW}[!] Backing up existing $cfg to $BACKUP_NAME${NC}"
        mv "$TARGET" "$TARGET_DIR/$BACKUP_NAME"
    fi

    # Create Symlink
    echo -e "${BLUE}[*] Linking $cfg...${NC}"
    ln -s "$SOURCE" "$TARGET"
done

# Copy default wallpaper if none exists
if [ ! -d "$HOME/Pictures/Wallpapers" ]; then
    mkdir -p "$HOME/Pictures/Wallpapers"
fi

# Link or copy assets
# For now, we assume an assets folder exists.
if [ -f "$PROJECT_DIR/assets/md3_default.jpg" ]; then
     cp "$PROJECT_DIR/assets/md3_default.jpg" "$HOME/Pictures/Wallpapers/md3_default.jpg"
fi

echo -e "${GREEN}[+] Configuration linking complete.${NC}"
