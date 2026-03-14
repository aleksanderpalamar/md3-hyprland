#!/bin/bash
set -euo pipefail

# shellcheck source=lib/common.sh
source "$(dirname "$0")/lib/common.sh"

# Kill running waybar instances
killall waybar || true

# Wait for process to end
while pgrep -x waybar >/dev/null; do sleep 0.1; done

# Start waybar
waybar &

# Send notification
notify-send "$(i18n MSG_WAYBAR_RELOADED)" "$(i18n MSG_WAYBAR_RELOAD_OK)" -i waybar
