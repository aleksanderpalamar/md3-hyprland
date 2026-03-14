#!/bin/bash
# License: GPLv3
# Author: Aleksander Palamar
# UI reload helper for MD3 Hyprland

reload_ui() {
    pkill -SIGUSR2 waybar 2>/dev/null || true
    swaync-client -rs 2>/dev/null || true
    hyprctl reload 2>/dev/null || true
}
