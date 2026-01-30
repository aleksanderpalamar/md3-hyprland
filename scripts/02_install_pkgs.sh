#!/bin/bash
# License: GPLv3
# Main Installer for MD3-Hyprland
# Author: Aleksander Palamar

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[*] Starting Package Installation...${NC}"

# Core Packages
PKGS=(
    "hyprland"
    "waybar"
    "rofi-wayland"
    "hyprpaper"
    "matugen-bin"
    "swaync"
    "dolphin"
    "kitty"
    "qt5-wayland"
    "qt6-wayland"
    "ttf-roboto"
    "ttf-jetbrains-mono-nerd"
    "grim"
    "slurp"
    "wl-clipboard"
    "polkit-kde-agent" 
    "xdg-desktop-portal-hyprland"
    "gnome-calendar"
    "nautilus"
)

echo -e "${BLUE}[*] The following packages will be installed:${NC}"
echo "${PKGS[*]}"

# Install using yay
# --needed skips up-to-date packages
# --noconfirm for automation (use with caution, maybe remove for user interactive preference? User asked for automation project, so noconfirm is appropriate but I will keep it interactive for sudo prompts)
yay -S --needed --noconfirm "${PKGS[@]}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] Packages installed successfully.${NC}"
else
    echo -e "${RED}[!] Error installing packages.${NC}"
    exit 1
fi
