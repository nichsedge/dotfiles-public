#!/usr/bin/env bash
# macOS-style screenshot utility for Hyprland
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILE="$DIR/Screenshot_${TIMESTAMP}.png"

case "$1" in
    full)
        grim "$FILE"
        if [ -f "$FILE" ]; then
            wl-copy < "$FILE"
            notify-send -i "$FILE" "Screenshot Taken" "Full screen saved to $(basename "$FILE") & copied"
        fi
        ;;
    area)
        GEOM=$(slurp)
        if [ -n "$GEOM" ]; then
            grim -g "$GEOM" "$FILE"
            if [ -f "$FILE" ]; then
                wl-copy < "$FILE"
                notify-send -i "$FILE" "Screenshot Taken" "Selected region saved to $(basename "$FILE") & copied"
            fi
        fi
        ;;
    window)
        # Capture focused window
        GEOM=$(hyprctl -j activewindow 2>/dev/null | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' 2>/dev/null)
        if [ -n "$GEOM" ] && [ "$GEOM" != "x" ]; then
            grim -g "$GEOM" "$FILE"
            if [ -f "$FILE" ]; then
                wl-copy < "$FILE"
                notify-send -i "$FILE" "Screenshot Taken" "Active window saved to $(basename "$FILE") & copied"
            fi
        else
            GEOM=$(slurp)
            if [ -n "$GEOM" ]; then
                grim -g "$GEOM" "$FILE"
                if [ -f "$FILE" ]; then
                    wl-copy < "$FILE"
                    notify-send -i "$FILE" "Screenshot Taken" "Saved to $(basename "$FILE") & copied"
                fi
            fi
        fi
        ;;
    *)
        echo "Usage: $0 {full|area|window}"
        exit 1
        ;;
esac
