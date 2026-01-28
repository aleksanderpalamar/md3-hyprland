#!/bin/bash

# Recarregar configurações do Hyprland
hyprctl reload

# Reiniciar Waybar
killall waybar
waybar &

# Recarregar SwayNC
swaync-client -R
swaync-client -rs

# Notificar
notify-send "Hyprland" "Configuration reloaded successfully!" -i software-update-available