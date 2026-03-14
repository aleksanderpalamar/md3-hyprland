#!/bin/bash
set -euo pipefail
# License: GPLv3
# Author: Aleksander Palamar
# Generates config/swaync/config.json from template with i18n strings

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh"

TEMPLATE="$MD3_PROJECT_ROOT/config/swaync/config.json.template"
OUTPUT="$MD3_PROJECT_ROOT/config/swaync/config.json"

if [ ! -f "$TEMPLATE" ]; then
    echo "Error: SwayNC template not found at $TEMPLATE"
    exit 1
fi

# Replace placeholders with i18n values
sed \
    -e "s|{{MSG_SWAYNC_TITLE}}|$(i18n MSG_SWAYNC_TITLE)|g" \
    -e "s|{{MSG_SWAYNC_CLEAR}}|$(i18n MSG_SWAYNC_CLEAR)|g" \
    -e "s|{{MSG_SWAYNC_DND}}|$(i18n MSG_SWAYNC_DND)|g" \
    -e "s|{{MSG_SWAYNC_VOLUME}}|$(i18n MSG_SWAYNC_VOLUME)|g" \
    -e "s|{{MSG_SWAYNC_BRIGHTNESS}}|$(i18n MSG_SWAYNC_BRIGHTNESS)|g" \
    "$TEMPLATE" > "$OUTPUT"

echo "Generated $OUTPUT"
