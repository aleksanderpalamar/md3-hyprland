#!/bin/bash
# License: GPLv3
# Main Installer for MD3-Hyprland
# Author: Aleksander Palamar

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

WALLPAPER_PATH="$HOME/Pictures/Wallpapers/md3_default.jpg"

echo -e "${BLUE}[*] Running Post-Install setup...${NC}"

# 1. Ensure Wallpaper exists (Download if missing)
if [ ! -f "$WALLPAPER_PATH" ]; then
    echo -e "${BLUE}[*] Downloading default wallpaper...${NC}"
    # Minimalistic abstract gradient, reliable URL
    curl -L -o "$WALLPAPER_PATH" "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop"
fi

# 2. Run Matugen to generate colors
if command -v matugen &> /dev/null; then
    echo -e "${BLUE}[*] Generating Material Design 3 colors from wallpaper...${NC}"
    # Ensure we use the config file which should be linked at ~/.config/matugen/config.toml
    MATUGEN_CONF="$HOME/.config/matugen/config.toml"
    if [ -f "$MATUGEN_CONF" ]; then
        # Default to dark mode for initial setup
        matugen image "$WALLPAPER_PATH" -c "$MATUGEN_CONF" -m dark
    else
        echo -e "${YELLOW}[!] Matugen config not found at $MATUGEN_CONF. Using default generation...${NC}"
        matugen image "$WALLPAPER_PATH"
    fi
else
    echo -e "${RED}[!] Matugen not found. Skipping color generation.${NC}"
fi

echo -e "${GREEN}[+] Setup Complete!${NC}"
echo -e "${GREEN}[+] Please restart your session or type 'Hyprland' to start.${NC}"
echo -e "${GREEN}[+] Use 'Super + Q' to open Kitty, 'Super + Space' for Rofi.${NC}"
