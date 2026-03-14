#!/bin/bash
# License: GPLv3
# Main Installer for MD3-Hyprland
# Author: Aleksander Palamar

set -euo pipefail

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

# 3. Check required commands
REQUIRED_CMDS=("hyprctl" "matugen" "rofi" "jq" "waybar" "swaync-client")
MISSING=()
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING+=("$cmd")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo -e "${YELLOW}[!] Missing commands (will be installed): ${MISSING[*]}${NC}"
else
    echo -e "${GREEN}[+] All required commands found.${NC}"
fi

# 4. Check bash version >= 4
BASH_MAJOR="${BASH_VERSINFO[0]}"
if [ "$BASH_MAJOR" -ge 4 ]; then
    echo -e "${GREEN}[+] Bash version $BASH_VERSION (>= 4).${NC}"
else
    echo -e "${RED}[!] Bash version $BASH_VERSION is too old. Bash >= 4 required.${NC}"
    exit 1
fi

# 5. Detect Install vs Update State
CONFIG_DIR="$HOME/.config"
if [ -d "$CONFIG_DIR/hypr" ] || [ -d "$CONFIG_DIR/waybar" ]; then
    echo -e "${YELLOW}[!] Existing configurations found. This will be an UPDATE/OVERWRITE.${NC}"
    export INSTALL_TYPE="UPDATE"
else
    echo -e "${GREEN}[+] Clean environment detected. This will be a FRESH INSTALL.${NC}"
    export INSTALL_TYPE="FRESH"
fi

echo -e "${BLUE}[*] Environment check complete. Mode: $INSTALL_TYPE${NC}"
