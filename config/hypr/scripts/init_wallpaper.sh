#!/bin/bash
set -euo pipefail
# License: GPLv3
# Author: Aleksander Palamar

# shellcheck source=lib/common.sh
source "$(dirname "$0")/lib/common.sh"

# Kill any existing instance to prevent conflicts
pkill hyprpaper || true
sleep 0.5

# Start hyprpaper in background
hyprpaper &
PID=$!
disown $PID

echo "Waiting for hyprpaper..."
for i in {1..20}; do
    if hyprctl hyprpaper listloaded >/dev/null 2>&1; then
        echo "Hyprpaper ready."
        break
    fi
    sleep 0.2
done

# If config exists, try to force apply the wallpaper
if [ -f "$HYPRPAPER_CONFIG" ]; then
    WALLPAPER_PATH=$(get_current_wallpaper)

    if [ -n "$WALLPAPER_PATH" ]; then
        echo "Applying wallpaper: $WALLPAPER_PATH"

        # Preload first
        hyprctl hyprpaper preload "$WALLPAPER_PATH"

        # Get monitors
        MONITORS=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

        if [ -n "$MONITORS" ]; then
            for mon in $MONITORS; do
                echo "Setting wallpaper on $mon"
                hyprctl hyprpaper wallpaper "$mon,$WALLPAPER_PATH"
            done
        else
            echo "No monitors found via hyprctl, using wildcard."
            hyprctl hyprpaper wallpaper ",$WALLPAPER_PATH"
        fi

        # Apply Matugen colors
        echo "Running matugen..."
        THEME_MODE=$(get_theme_mode)
        matugen image "$WALLPAPER_PATH" -c "$MATUGEN_CONFIG" -m "$THEME_MODE" &
        wait

        # Reload UI
        echo "Reloading UI..."
        reload_ui
    fi
fi
