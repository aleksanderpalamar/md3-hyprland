#!/bin/bash
# License: GPLv3
# Main Installer for MD3-Hyprland
# Author: Aleksander Palamar

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}[*] Checking Environment...${NC}"

# 1. Check for Arch Linux
if [ -f /etc/arch-release ]; then
    echo -e "${GREEN}[+] Arch Linux detected.${NC}"
else
    echo -e "${RED}[!] This script is designed for Arch Linux.${NC}"
    exit 1
fi

# 2. Check for AUR Helper (yay)
if command -v yay &> /dev/null; then
    echo -e "${GREEN}[+] 'yay' is installed.${NC}"
else
    echo -e "${YELLOW}[!] 'yay' not found. This script requires an AUR helper.${NC}"
    echo -e "${YELLOW}[!] Attempting to install 'yay-bin' manually...${NC}"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay-bin
    
    if command -v yay &> /dev/null; then
        echo -e "${GREEN}[+] 'yay' successfully installed.${NC}"
    else
        echo -e "${RED}[!] Failed to install 'yay'. Aborting.${NC}"
        exit 1
    fi
fi

# 3. Detect Install vs Update State
# We check if crucial config directories already exist
CONFIG_DIR="$HOME/.config"
if [ -d "$CONFIG_DIR/hypr" ] || [ -d "$CONFIG_DIR/waybar" ]; then
    echo -e "${YELLOW}[!] Existing configurations found. This will be an UPDATE/OVERWRITE.${NC}"
    export INSTALL_TYPE="UPDATE"
else
    echo -e "${GREEN}[+] Clean environment detected. This will be a FRESH INSTALL.${NC}"
    export INSTALL_TYPE="FRESH"
fi

echo -e "${BLUE}[*] Environment check complete. Mode: $INSTALL_TYPE${NC}"
