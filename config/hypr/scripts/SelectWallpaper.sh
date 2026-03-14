#!/bin/bash
set -euo pipefail

# shellcheck source=lib/common.sh
source "$(dirname "$0")/lib/common.sh"

if ! pgrep -x "hyprpaper" > /dev/null; then
    hyprpaper &
    sleep 0.5
fi

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify_error "$(i18n MSG_WALLPAPER_DIR_NOT_FOUND) $WALLPAPER_DIR"
    exit 1
fi

cd "$WALLPAPER_DIR"

selected_wallpaper=$(find . -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) -printf "%T@ %f\n" | sort -nr | cut -d' ' -f2- | rofi -dmenu -i -p "$(i18n MSG_WALLPAPER_CHOOSE)")

if [ -n "$selected_wallpaper" ]; then
    full_path="$WALLPAPER_DIR/$selected_wallpaper"

    hyprctl hyprpaper unload all
    hyprctl hyprpaper preload "$full_path"
    hyprctl hyprpaper wallpaper ",$full_path"

    sed -i "s#^preload = .*#preload = $full_path#" "$HYPRPAPER_CONFIG"
    sed -i "s#^wallpaper = .*#wallpaper = ,$full_path#" "$HYPRPAPER_CONFIG"

    # Generate colors from new wallpaper via Matugen
    THEME_MODE=$(get_theme_mode)
    if command -v matugen &> /dev/null; then
        matugen image "$full_path" -c "$MATUGEN_CONFIG" -m "$THEME_MODE"
    fi

    reload_ui

    notify-send "$(i18n MSG_WALLPAPER_CHANGED)" "$(i18n MSG_WALLPAPER_SET_TO) $selected_wallpaper" -i "$full_path"
fi
