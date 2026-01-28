#!/bin/bash
# License: GPLv3
# Author: Aleksander Palamar
# Define paths
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"

# Kill any existing instance to prevent conflicts
pkill hyprpaper
sleep 0.5

# Start hyprpaper in background
hyprpaper &
PID=$!
disown $PID

# Wait for hyprpaper to initialize socket (loop up to 5 seconds)
# We check if the socket exists.
# Note: Location depends on hyprland version, usually $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.hyprpaper.sock
# or just check if 'hyprctl hyprpaper listloaded' returns success.

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

        # Apply Wallust colors
        echo "Running wallust..."
        wallust run "$WALLPAPER_PATH" &

        # Reload UI
        echo "Reloading UI..."
        pkill -SIGUSR2 waybar
        swaync-client -rs
        hyprctl reload
    fi
fi