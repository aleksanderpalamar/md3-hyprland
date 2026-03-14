#!/bin/bash
set -uo pipefail

# shellcheck source=lib/common.sh
source "$(dirname "$0")/lib/common.sh"

CONFIG_FILE="$HOME/.config/hypr/UserConfigs/UserKeybinds.conf"

if pidof rofi > /dev/null; then
    pkill rofi
fi

# Function to get friendly description
get_friendly_description() {
    local action="$1"
    local command="$2"
    local key="$3"
    local mod="$4"

    # Application launchers
    [[ "$command" == *"terminal"* || "$command" == *"kitty"* ]] && echo "$(i18n MSG_HOTKEY_OPEN_TERMINAL)" && return
    [[ "$command" == *"fileManager"* || "$command" == *"thunar"* || "$command" == *"nautilus"* ]] && echo "$(i18n MSG_HOTKEY_OPEN_FILE_MANAGER)" && return
    [[ "$command" == *"search"* || "$command" == *"Search"* ]] && echo "$(i18n MSG_HOTKEY_WEB_SEARCH)" && return
    [[ "$command" == *"msedge"* || "$command" == *"browser"* ]] && echo "$(i18n MSG_HOTKEY_OPEN_BROWSER)" && return
    [[ "$command" == *"warpterminal"* ]] && echo "$(i18n MSG_HOTKEY_OPEN_WARP)" && return
    [[ "$command" == *"rofi -show drun"* ]] && echo "$(i18n MSG_HOTKEY_APP_LAUNCHER)" && return

    # Window management
    [[ "$action" == "killactive" ]] && echo "$(i18n MSG_HOTKEY_CLOSE_WINDOW)" && return
    [[ "$action" == "exit" ]] && echo "$(i18n MSG_HOTKEY_EXIT_HYPRLAND)" && return
    [[ "$action" == "togglefloating" ]] && echo "$(i18n MSG_HOTKEY_TOGGLE_FLOATING)" && return
    [[ "$action" == "pseudo" ]] && echo "$(i18n MSG_HOTKEY_PSEUDO)" && return
    [[ "$action" == "togglesplit" ]] && echo "$(i18n MSG_HOTKEY_TOGGLE_SPLIT)" && return

    # Focus movement
    [[ "$action" == "movefocus" && "$command" == "l" ]] && echo "$(i18n MSG_HOTKEY_FOCUS_LEFT)" && return
    [[ "$action" == "movefocus" && "$command" == "r" ]] && echo "$(i18n MSG_HOTKEY_FOCUS_RIGHT)" && return
    [[ "$action" == "movefocus" && "$command" == "u" ]] && echo "$(i18n MSG_HOTKEY_FOCUS_UP)" && return
    [[ "$action" == "movefocus" && "$command" == "d" ]] && echo "$(i18n MSG_HOTKEY_FOCUS_DOWN)" && return

    # Workspaces
    [[ "$action" == "workspace" && "$command" =~ ^[0-9]+$ ]] && echo "$(i18n MSG_HOTKEY_GO_WORKSPACE) $command" && return
    [[ "$action" == "workspace" && "$command" == "e+1" ]] && echo "$(i18n MSG_HOTKEY_NEXT_WORKSPACE)" && return
    [[ "$action" == "workspace" && "$command" == "e-1" ]] && echo "$(i18n MSG_HOTKEY_PREV_WORKSPACE)" && return
    [[ "$action" == "movetoworkspace" && "$command" =~ ^[0-9]+$ ]] && echo "$(i18n MSG_HOTKEY_MOVE_TO_WORKSPACE) $command" && return
    [[ "$action" == "togglespecialworkspace" ]] && echo "$(i18n MSG_HOTKEY_TOGGLE_SPECIAL)" && return
    [[ "$action" == "movetoworkspace" && "$command" == *"special"* ]] && echo "$(i18n MSG_HOTKEY_MOVE_TO_SPECIAL)" && return

    # Scripts
    [[ "$command" == *"waybar"* ]] && echo "$(i18n MSG_HOTKEY_RESTART_WAYBAR)" && return
    [[ "$command" == *"grim"* ]] && echo "$(i18n MSG_HOTKEY_SCREENSHOT)" && return
    [[ "$command" == *"SelectWallpaper"* ]] && echo "$(i18n MSG_HOTKEY_SELECT_WALLPAPER)" && return
    [[ "$command" == *"Wlogout"* ]] && echo "$(i18n MSG_HOTKEY_LOGOUT_MENU)" && return
    [[ "$command" == *"LockScreen"* ]] && echo "$(i18n MSG_HOTKEY_LOCK_SCREEN)" && return
    [[ "$command" == *"ShowHotkeys"* ]] && echo "$(i18n MSG_HOTKEY_SHOW_HOTKEYS)" && return

    # Mouse actions
    [[ "$action" == "movewindow" ]] && echo "$(i18n MSG_HOTKEY_MOVE_WINDOW_MOUSE)" && return
    [[ "$action" == "resizewindow" ]] && echo "$(i18n MSG_HOTKEY_RESIZE_WINDOW_MOUSE)" && return

    # Multimedia
    [[ "$command" == *"AudioRaiseVolume"* || "$command" == *"set-volume"*"+"* ]] && echo "$(i18n MSG_HOTKEY_VOLUME_UP)" && return
    [[ "$command" == *"AudioLowerVolume"* || "$command" == *"set-volume"*"-"* ]] && echo "$(i18n MSG_HOTKEY_VOLUME_DOWN)" && return
    [[ "$command" == *"AudioMute"*"SINK"* || "$command" == *"set-mute"*"SINK"* ]] && echo "$(i18n MSG_HOTKEY_VOLUME_MUTE)" && return
    [[ "$command" == *"AudioMicMute"* || "$command" == *"set-mute"*"SOURCE"* ]] && echo "$(i18n MSG_HOTKEY_MIC_MUTE)" && return
    [[ "$command" == *"MonBrightnessUp"* || "$command" == *"brightnessctl"*"+"* ]] && echo "$(i18n MSG_HOTKEY_BRIGHTNESS_UP)" && return
    [[ "$command" == *"MonBrightnessDown"* || "$command" == *"brightnessctl"*"-"* ]] && echo "$(i18n MSG_HOTKEY_BRIGHTNESS_DOWN)" && return
    [[ "$command" == *"playerctl next"* ]] && echo "$(i18n MSG_HOTKEY_NEXT_TRACK)" && return
    [[ "$command" == *"playerctl play-pause"* ]] && echo "$(i18n MSG_HOTKEY_PLAY_PAUSE)" && return
    [[ "$command" == *"playerctl previous"* ]] && echo "$(i18n MSG_HOTKEY_PREV_TRACK)" && return

    # Default fallback
    echo "$action $command"
}

parse_keybinds() {
    local config_file="$1"
    local main_mod="SUPER"

    grep '^bind' "$config_file" | while IFS= read -r line; do
        line=$(echo "$line" | sed 's/^bind[mel]* = //' | sed 's/,$//')

        line=$(echo "$line" | sed "s/\$mainMod/$main_mod/")

        IFS=',' read -r mod key action command <<< "$line"

        mod=$(echo "$mod" | xargs)
        key=$(echo "$key" | xargs)
        action=$(echo "$action" | xargs)
        command=$(echo "$command" | xargs)

        [[ -z "$key" ]] && continue

        if [[ "$mod" == "$main_mod" ]]; then
            keybind="SUPER + $key"
        elif [[ -z "$mod" ]]; then
            keybind="$key"
        else
            keybind="$mod + $key"
        fi

        description=$(get_friendly_description "$action" "$command" "$key" "$mod")

        printf "%-30s | %s\n" "$keybind" "$description"
    done
}

parse_keybinds "$CONFIG_FILE" | rofi -dmenu -i -p "$(i18n MSG_HOTKEY_TITLE)" -theme-str 'window {width: 800px;}'
