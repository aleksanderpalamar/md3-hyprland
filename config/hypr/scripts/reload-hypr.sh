#!/bin/bash
set -euo pipefail
# License: GPLv3
# Author: Aleksander Palamar

# shellcheck source=lib/common.sh
source "$(dirname "$0")/lib/common.sh"

# Reload Hyprland
hyprctl reload

# Restart Waybar
killall waybar || true
waybar &

# Reload SwayNC
swaync-client -R
swaync-client -rs

# Notify
notify-send "$(i18n MSG_HYPRLAND_RELOADED)" "$(i18n MSG_CONFIG_RELOADED)" -i software-update-available
