#!/bin/bash
set -euo pipefail
# License: GPLv3
# Author: Aleksander Palamar
# Uninstaller for MD3 Hyprland Setup

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET_DIR="$HOME/.config"
CONFIGS=("hypr" "waybar" "rofi" "kitty" "swaync" "matugen")

echo "========================================="
echo "   MD3 Hyprland Uninstaller"
echo "========================================="
echo ""
echo -e "${YELLOW}This will remove MD3 Hyprland symlinks and restore backups.${NC}"
echo -e "${YELLOW}Isso removerá os symlinks do MD3 Hyprland e restaurará backups.${NC}"
echo ""
read -rp "Continue? / Continuar? [y/N] " confirm
if [[ "$confirm" != [yY] ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""

for cfg in "${CONFIGS[@]}"; do
    TARGET="$TARGET_DIR/$cfg"

    if [ -L "$TARGET" ]; then
        echo -e "${BLUE}[*] Removing symlink: $TARGET${NC}"
        rm "$TARGET"

        # Find most recent backup
        LATEST_BACKUP=$(find "$TARGET_DIR" -maxdepth 1 -name "${cfg}.backup_*" -type d 2>/dev/null | sort -r | head -n1)
        if [ -z "$LATEST_BACKUP" ]; then
            LATEST_BACKUP=$(find "$TARGET_DIR" -maxdepth 1 -name "${cfg}.backup_*" -type f 2>/dev/null | sort -r | head -n1)
        fi

        if [ -n "$LATEST_BACKUP" ]; then
            echo -e "${GREEN}[+] Restoring backup: $LATEST_BACKUP -> $TARGET${NC}"
            mv "$LATEST_BACKUP" "$TARGET"
        else
            echo -e "${YELLOW}[!] No backup found for $cfg.${NC}"
        fi
    elif [ -d "$TARGET" ] || [ -f "$TARGET" ]; then
        echo -e "${YELLOW}[!] $TARGET is not a symlink, skipping.${NC}"
    else
        echo -e "${YELLOW}[!] $TARGET does not exist, skipping.${NC}"
    fi
done

# Remove breadcrumb
if [ -f "$TARGET_DIR/md3-hyprland-root" ]; then
    rm "$TARGET_DIR/md3-hyprland-root"
    echo -e "${GREEN}[+] Removed project root breadcrumb.${NC}"
fi

# Remove setup flag
if [ -f "$TARGET_DIR/md3-hyprland-setup-done" ]; then
    rm "$TARGET_DIR/md3-hyprland-setup-done"
fi

# Remove cache
rm -f "$HOME/.cache/matugen_theme_mode"

echo ""
echo -e "${GREEN}[+] Uninstall complete.${NC}"
echo ""
echo -e "${YELLOW}The following packages were installed but NOT removed:${NC}"
echo "  hyprland waybar rofi kitty swaync matugen hyprpaper wlogout polkit-kde-agent"
echo ""
echo "To remove them manually:"
echo "  yay -Rns <package-name>"
