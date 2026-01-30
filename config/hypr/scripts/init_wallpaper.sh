#!/bin/bash
# License: GPLv3
# Author: Aleksander Palamar
# Define paths
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"
MATUGEN_CONFIG="$HOME/Projetos/md3-hyprland-setup/config/matugen/config.toml"

# Kill any existing instance to prevent conflicts
pkill hyprpaper
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
if [ -f "$CONFIG_FILE" ]; then
    # Extract the wallpaper path
    WALLPAPER_PATH=$(grep "^wallpaper =" "$CONFIG_FILE" | head -n 1 | cut -d',' -f2 | xargs)
    
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
        
        # Check for saved theme mode
        STATE_FILE="$HOME/.cache/matugen_theme_mode"
        if [ -f "$STATE_FILE" ]; then
            THEME_MODE=$(cat "$STATE_FILE")
        else
            THEME_MODE="dark"
        fi
        
        # Run Matugen with correct mode
        # Note: we use 'matugen image' with -m flag
        if [ "$THEME_MODE" == "light" ]; then
            matugen image "$WALLPAPER_PATH" -c "$MATUGEN_CONFIG" -m light &
        else
            matugen image "$WALLPAPER_PATH" -c "$MATUGEN_CONFIG" -m dark &
        fi
        
        # Wait for matugen (since it's fast) then reload
        wait
        
        # Reload UI
        echo "Reloading UI..."
        pkill -SIGUSR2 waybar
        swaync-client -rs
        hyprctl reload
    fi
fi
