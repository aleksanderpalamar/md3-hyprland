#!/bin/bash
set -euo pipefail

# shellcheck source=lib/common.sh
source "$(dirname "$0")/lib/common.sh"

# Read current mode, default to dark if not set
CURRENT_MODE=$(get_theme_mode)

# Toggle mode
if [ "$CURRENT_MODE" == "dark" ]; then
    NEW_MODE="light"
else
    NEW_MODE="dark"
fi

echo "Switching to $NEW_MODE mode..."

# Save new mode
echo "$NEW_MODE" > "$THEME_STATE_FILE"

# Get current wallpaper
WALLPAPER_PATH=$(get_current_wallpaper)

if [ -n "$WALLPAPER_PATH" ]; then
    echo "Reapplying matugen with mode $NEW_MODE for $WALLPAPER_PATH"

    # Run Matugen
    matugen image "$WALLPAPER_PATH" -c "$MATUGEN_CONFIG" -m "$NEW_MODE"

    # Reload UI components
    echo "Reloading UI..."
    reload_ui

    # Send notification
    notify-send "$(i18n MSG_THEME_CHANGED)" "$(i18n MSG_THEME_SWITCHED_TO) $NEW_MODE $(i18n MSG_THEME_MODE)" -i preferences-desktop-theme
else
    echo "Error: Could not determine wallpaper path from $HYPRPAPER_CONFIG"
    notify_error "$(i18n MSG_THEME_ERROR)"
fi
