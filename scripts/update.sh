#!/bin/bash
set -euo pipefail
# License: GPLv3
# Author: Aleksander Palamar
# Update script for MD3 Hyprland Setup

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Resolve project root
HYPR_LINK="$HOME/.config/hypr"
if [ -L "$HYPR_LINK" ]; then
    REAL_PATH=$(readlink -f "$HYPR_LINK")
    PROJECT_DIR="$(dirname "$(dirname "$REAL_PATH")")"
elif [ -f "$HOME/.config/md3-hyprland-root" ]; then
    PROJECT_DIR=$(cat "$HOME/.config/md3-hyprland-root")
else
    echo -e "${RED}[!] Could not resolve project directory.${NC}"
    exit 1
fi

cd "$PROJECT_DIR"

echo "========================================="
echo "   MD3 Hyprland Updater"
echo "========================================="
echo ""

# 1. Git pull
echo -e "${BLUE}[*] Pulling latest changes...${NC}"
git pull --rebase || {
    echo -e "${RED}[!] Git pull failed. Please resolve conflicts manually.${NC}"
    exit 1
}

# 2. Copy new UserConfigs templates only if they don't exist
echo -e "${BLUE}[*] Checking for new UserConfigs templates...${NC}"
USER_CONFIGS_DIR="$HOME/.config/hypr/UserConfigs"
TEMPLATE_DIR="$PROJECT_DIR/config/hypr/UserConfigs"

if [ -d "$TEMPLATE_DIR" ]; then
    for template in "$TEMPLATE_DIR"/*.conf; do
        [ -f "$template" ] || continue
        basename=$(basename "$template")
        if [ ! -f "$USER_CONFIGS_DIR/$basename" ]; then
            echo -e "${GREEN}[+] New template: $basename${NC}"
            cp "$template" "$USER_CONFIGS_DIR/$basename"
        fi
    done
fi

# 3. Re-run Matugen with current wallpaper and theme
echo -e "${BLUE}[*] Regenerating colors...${NC}"
STATE_FILE="$HOME/.cache/matugen_theme_mode"
HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"
MATUGEN_CONFIG="$PROJECT_DIR/config/matugen/config.toml"

THEME_MODE="dark"
if [ -f "$STATE_FILE" ]; then
    THEME_MODE=$(cat "$STATE_FILE")
fi

if [ -f "$HYPRPAPER_CONFIG" ]; then
    WALLPAPER_PATH=$(grep "^wallpaper =" "$HYPRPAPER_CONFIG" | head -n 1 | cut -d',' -f2 | xargs)
    if [ -n "$WALLPAPER_PATH" ] && command -v matugen &> /dev/null; then
        matugen image "$WALLPAPER_PATH" -c "$MATUGEN_CONFIG" -m "$THEME_MODE" || true
    fi
fi

# 4. Regenerate SwayNC config
echo -e "${BLUE}[*] Regenerating SwayNC config...${NC}"
bash "$PROJECT_DIR/config/hypr/scripts/lib/generate_swaync_config.sh" || true

# 5. Make scripts executable
chmod +x "$PROJECT_DIR"/config/hypr/scripts/*.sh "$PROJECT_DIR"/config/hypr/scripts/lib/*.sh 2>/dev/null || true

# 6. Reload UI
echo -e "${BLUE}[*] Reloading UI...${NC}"
pkill -SIGUSR2 waybar 2>/dev/null || true
swaync-client -rs 2>/dev/null || true
hyprctl reload 2>/dev/null || true

echo ""
echo -e "${GREEN}[+] Update complete!${NC}"
