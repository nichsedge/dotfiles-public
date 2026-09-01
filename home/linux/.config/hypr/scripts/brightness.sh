#!/usr/bin/env bash
# Brightness control with on-screen notification feedback
case "$1" in
    up)
        brightnessctl set +5%
        ;;
    down)
        brightnessctl set 5%-
        ;;
esac

BRIGHT=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Brightness" "${BRIGHT}%" -h int:value:"${BRIGHT}" -t 1200
