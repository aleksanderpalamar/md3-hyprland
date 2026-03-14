#!/bin/bash
set -euo pipefail
# License: GPLv3
# Author: Aleksander Palamar
# First-use wizard: runs once on first login to configure basics

SETUP_FLAG="$HOME/.config/md3-hyprland-setup-done"

# If already configured, exit silently
if [ -f "$SETUP_FLAG" ]; then
    exit 0
fi

# shellcheck source=lib/common.sh
source "$(dirname "$0")/lib/common.sh"

# Step 1: Choose language
LANG_CHOICE=$(printf "English\nPortuguês (Brasil)" | rofi -dmenu -i -p "$(i18n MSG_WIZARD_CHOOSE_LANG)")

if [ "$LANG_CHOICE" = "Português (Brasil)" ]; then
    CHOSEN_LOCALE="pt_BR"
else
    CHOSEN_LOCALE="en_US"
fi

# Reload i18n with chosen locale
export MD3_LOCALE="$CHOSEN_LOCALE"
source "$(dirname "$0")/lib/i18n.sh"

# Step 2: Choose wallpaper
if [ -d "$WALLPAPER_DIR" ]; then
    WALLPAPERS=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -printf "%f\n" | sort)
    if [ -n "$WALLPAPERS" ]; then
        CHOSEN_WALL=$(echo "$WALLPAPERS" | rofi -dmenu -i -p "$(i18n MSG_WIZARD_CHOOSE_WALLPAPER)")
        if [ -n "$CHOSEN_WALL" ]; then
            WALL_PATH="$WALLPAPER_DIR/$CHOSEN_WALL"
            # Update hyprpaper config
            cat > "$HYPRPAPER_CONFIG" <<EOF
preload = $WALL_PATH
wallpaper = ,$WALL_PATH
EOF
        fi
    fi
fi

# Step 3: Choose theme (dark/light)
THEME_CHOICE=$(printf "%s\n%s" "$(i18n MSG_THEME_DARK)" "$(i18n MSG_THEME_LIGHT)" | rofi -dmenu -i -p "$(i18n MSG_WIZARD_CHOOSE_THEME)")

if [ "$THEME_CHOICE" = "$(i18n MSG_THEME_LIGHT)" ]; then
    echo "light" > "$THEME_STATE_FILE"
else
    echo "dark" > "$THEME_STATE_FILE"
fi

# Step 4: Choose keyboard layout
KB_LAYOUT=$(printf "us\nbr\nde\nfr\nes\nit\npt\ngb\nru\njp" | rofi -dmenu -i -p "$(i18n MSG_WIZARD_CHOOSE_KB_LAYOUT)")

if [ -n "$KB_LAYOUT" ]; then
    # Write to UserInput.conf
    USER_INPUT="$HOME/.config/hypr/UserConfigs/UserInput.conf"
    cat > "$USER_INPUT" <<EOF
# User Input Configuration
source = ~/.config/hypr/input.conf

input {
    kb_layout = $KB_LAYOUT
}
EOF
fi

# Write locale to ENVariables.conf if not en_US
if [ "$CHOSEN_LOCALE" != "en_US" ]; then
    ENV_FILE="$HOME/.config/hypr/UserConfigs/ENVariables.conf"
    if ! grep -q "MD3_LOCALE" "$ENV_FILE" 2>/dev/null; then
        echo "" >> "$ENV_FILE"
        echo "env = MD3_LOCALE,$CHOSEN_LOCALE" >> "$ENV_FILE"
    fi
fi

# Apply Matugen with chosen settings
WALL_PATH=$(get_current_wallpaper)
THEME_MODE=$(get_theme_mode)
if [ -n "$WALL_PATH" ] && command -v matugen &> /dev/null; then
    matugen image "$WALL_PATH" -c "$MATUGEN_CONFIG" -m "$THEME_MODE" || true
fi

# Generate SwayNC config with chosen locale
bash "$(dirname "$0")/lib/generate_swaync_config.sh" || true

# Mark setup as done
touch "$SETUP_FLAG"

# Reload UI
reload_ui

notify-send "$(i18n MSG_WIZARD_TITLE)" "$(i18n MSG_WIZARD_DONE)"
