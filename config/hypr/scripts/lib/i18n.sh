#!/bin/bash
# License: GPLv3
# Author: Aleksander Palamar
# Internationalization loader for MD3 Hyprland

_I18N_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/locale"

# Determine locale: MD3_LOCALE > LANG > fallback en_US
_MD3_LANG="${MD3_LOCALE:-${LANG%%.*}}"
_MD3_LANG="${_MD3_LANG:-en_US}"

# Always load English first as fallback
# shellcheck source=locale/en_US.sh
source "$_I18N_DIR/en_US.sh"

# Then overlay the user's locale if different and available
if [ "$_MD3_LANG" != "en_US" ] && [ -f "$_I18N_DIR/${_MD3_LANG}.sh" ]; then
    # shellcheck source=locale/pt_BR.sh
    source "$_I18N_DIR/${_MD3_LANG}.sh"
fi

# Lookup function: i18n KEY -> prints the value of MSG variable
i18n() {
    local key="$1"
    local val="${!key}"
    if [ -n "$val" ]; then
        echo "$val"
    else
        echo "$key"
    fi
}
