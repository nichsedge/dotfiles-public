#!/usr/bin/env bash
# Audio control with on-screen notification feedback
case "$1" in
    up)
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
esac

VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -i 'MUTED')

if [ -n "$MUTED" ]; then
    notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Volume" "Muted" -h int:value:0 -t 1200
else
    notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Volume" "${VOL}%" -h int:value:"${VOL}" -t 1200
fi
