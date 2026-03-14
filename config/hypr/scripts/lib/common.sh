#!/bin/bash
# License: GPLv3
# Author: Aleksander Palamar
# Common helpers for MD3 Hyprland scripts

# Resolve project root via symlink or breadcrumb
_resolve_project_root() {
    local hypr_link="$HOME/.config/hypr"
    if [ -L "$hypr_link" ]; then
        local real_path
        real_path=$(readlink -f "$hypr_link")
        # Go up 2 levels: config/hypr -> config -> project root
        echo "$(dirname "$(dirname "$real_path")")"
    elif [ -f "$HOME/.config/md3-hyprland-root" ]; then
        cat "$HOME/.config/md3-hyprland-root"
    else
        echo "$HOME/Projetos/md3-hyprland-setup"
    fi
}

export MD3_PROJECT_ROOT="${MD3_PROJECT_ROOT:-$(_resolve_project_root)}"
export MATUGEN_CONFIG="$MD3_PROJECT_ROOT/config/matugen/config.toml"
export WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
export THEME_STATE_FILE="$HOME/.cache/matugen_theme_mode"
export HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"

# Load i18n
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/i18n.sh
source "$LIB_DIR/i18n.sh"
# shellcheck source=lib/ui_reload.sh
source "$LIB_DIR/ui_reload.sh"

# Notification helpers
notify_error() {
    notify-send -u critical "$(i18n MSG_ERROR)" "$1"
}

notify_info() {
    notify-send "$(i18n MSG_INFO)" "$1"
}

# Get current theme mode (dark/light)
get_theme_mode() {
    if [ -f "$THEME_STATE_FILE" ]; then
        cat "$THEME_STATE_FILE"
    else
        echo "dark"
    fi
}

# Get current wallpaper path from hyprpaper config
get_current_wallpaper() {
    if [ -f "$HYPRPAPER_CONFIG" ]; then
        grep "^wallpaper =" "$HYPRPAPER_CONFIG" | head -n 1 | cut -d',' -f2 | xargs
    fi
}
