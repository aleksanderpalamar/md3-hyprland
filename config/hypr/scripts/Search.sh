#!/bin/bash
set -uo pipefail

# shellcheck source=lib/common.sh
source "$(dirname "$0")/lib/common.sh"

config_file="$HOME/.config/hypr/UserConfigs/MyPrograms.conf"
MAX_QUERY_LENGTH=1000

get_config() {
    local var_name="$1"
    if [[ -f "$config_file" ]]; then
        grep "^\s*\$$var_name\s*=" "$config_file" | sed 's/^.*=//;s/#.*//' | xargs | sed 's/^"//;s/"$//'
    fi
}

url_encode() {
    local string="$1"
    local length="${#string}"
    local encoded=""
    local i c

    for (( i = 0; i < length; i++ )); do
        c="${string:i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]) encoded+="$c" ;;
            *) printf -v encoded "%s%%%02X" "$encoded" "'$c" ;;
        esac
    done
    echo "$encoded"
}

if [[ ! -f "$config_file" ]]; then
    Search_Engine="https://duckduckgo.com/?q={}"
else
    Search_Engine=$(get_config "Search_Engine")
fi

if [[ -z "$Search_Engine" ]]; then
    Search_Engine="https://duckduckgo.com/?q={}"
fi

if [[ ! "$Search_Engine" =~ ^https?:// ]] || [[ "$Search_Engine" != *"{}"* ]]; then
     notify-send "$(i18n MSG_SEARCH_ERROR)" "$(i18n MSG_SEARCH_INVALID_ENGINE)"
     Search_Engine="https://duckduckgo.com/?q={}"
fi

rofi_theme="$HOME/.config/rofi/config-search.rasi"
msg='**note** search via default web browser'

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    sleep 0.1
fi

query=$(echo "" | rofi -dmenu -config "$rofi_theme" -mesg "$msg")

if [[ -n "$query" ]]; then
    query=$(echo "$query" | xargs)

    if [[ "${#query}" -gt "$MAX_QUERY_LENGTH" ]]; then
        notify-send "$(i18n MSG_SEARCH_ERROR)" "$(i18n MSG_SEARCH_QUERY_TOO_LONG) (max $MAX_QUERY_LENGTH chars)."
        exit 1
    fi

    if [[ -z "$query" ]]; then
        exit 0
    fi

    if command -v python3 &>/dev/null; then
        encoded_query=$(echo "$query" | python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read().strip()))")
    else
        encoded_query=$(url_encode "$query")
    fi

    url="${Search_Engine/\{\}/$encoded_query}"

    if [[ "$url" =~ ^https?:// ]]; then
        if ! xdg-open "$url"; then
            notify-send "$(i18n MSG_SEARCH_ERROR)" "$(i18n MSG_SEARCH_FAILED_BROWSER)"
        fi
    else
        notify-send "$(i18n MSG_SEARCH_ERROR)" "$(i18n MSG_SEARCH_BAD_URL)"
    fi
fi   
