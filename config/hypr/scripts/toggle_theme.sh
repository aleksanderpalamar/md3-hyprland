#!/bin/bash

# Define state file
STATE_FILE="$HOME/.cache/matugen_theme_mode"
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"
MATUGEN_CONFIG="$HOME/Projetos/md3-hyprland-setup/config/matugen/config.toml"

# Read current mode, default to dark if not set
if [ -f "$STATE_FILE" ]; then
    CURRENT_MODE=$(cat "$STATE_FILE")
else
    CURRENT_MODE="dark"
fi

# Toggle mode
if [ "$CURRENT_MODE" == "dark" ]; then
    NEW_MODE="light"
else
    NEW_MODE="dark"
fi

echo "Switching to $NEW_MODE mode..."

# Save new mode
echo "$NEW_MODE" > "$STATE_FILE"

# Get current wallpaper
if [ -f "$CONFIG_FILE" ]; then
    WALLPAPER_PATH=$(grep "^wallpaper =" "$CONFIG_FILE" | head -n 1 | cut -d',' -f2 | xargs)
    
    if [ -n "$WALLPAPER_PATH" ]; then
        echo "Reapplying matugen with mode $NEW_MODE for $WALLPAPER_PATH"
        
        # Run Matugen
        matugen image "$WALLPAPER_PATH" -c "$MATUGEN_CONFIG" -m "$NEW_MODE"
        
        # Reload UI components
        echo "Reloading UI..."
        
        # Waybar (reload CSS)
        pkill -SIGUSR2 waybar
        
        # SwayNC (reload CSS/Config)
        swaync-client -rs
        
        # Hyprland (reload variables/colors)
        hyprctl reload
        
        # Send notification
        notify-send "Theme Changed" "Switched to $NEW_MODE mode" -i preferences-desktop-theme
    else
        echo "Error: Could not determine wallpaper path from $CONFIG_FILE"
        notify-send "Theme Error" "Could not find wallpaper path" -u critical
    fi
else
    echo "Error: Config file $CONFIG_FILE not found"
fi
