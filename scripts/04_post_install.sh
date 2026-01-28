#!/bin/bash

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

# 2. Run Wallust to generate colors
if command -v wallust &> /dev/null; then
    echo -e "${BLUE}[*] Generating Material Design 3 colors from wallpaper...${NC}"
    wallust run "$WALLPAPER_PATH"
else
    echo -e "${RED}[!] Wallust not found. Skipping color generation.${NC}"
fi

echo -e "${GREEN}[+] Setup Complete!${NC}"
echo -e "${GREEN}[+] Please restart your session or type 'Hyprland' to start.${NC}"
echo -e "${GREEN}[+] Use 'Super + Q' to open Kitty, 'Super + Space' for Rofi.${NC}"
