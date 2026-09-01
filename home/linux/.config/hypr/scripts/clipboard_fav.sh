#!/usr/bin/env bash
# Save current clipboard item to favorites
FAV_FILE="$HOME/.config/clipboard_favorites"
mkdir -p "$(dirname "$FAV_FILE")"
current=$(wl-paste 2>/dev/null | head -c 200)
if [ -n "$current" ]; then
    echo "$current" >> "$FAV_FILE"
    # Deduplicate
    awk '!seen[$0]++' "$FAV_FILE" > "${FAV_FILE}.tmp" && mv "${FAV_FILE}.tmp" "$FAV_FILE"
    notify-send -i starred "Clipboard" "Added to favorites" -t 1500
else
    notify-send "Clipboard" "Clipboard empty" -t 1500
fi
