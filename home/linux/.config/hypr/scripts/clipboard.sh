#!/usr/bin/env bash
# macOS-style Clipboard History picker using cliphist + wofi
FAV_FILE="$HOME/.config/clipboard_favorites"
mkdir -p "$(dirname "$FAV_FILE")"

# Combine favorites + history
fav_items=""
if [ -f "$FAV_FILE" ]; then
    fav_items=$(cat "$FAV_FILE" | grep -v '^$' | sed 's/^/⭐ /')
fi

selected=$(cat - <(echo "$fav_items") <(cliphist list) | grep -v '^$' | wofi --dmenu --prompt "Clipboard + Favorites" --width 650 --height 450)
if [ -n "$selected" ]; then
    clean=$(echo "$selected" | sed 's/^⭐ //')
    tmp=$(mktemp)
    echo "$clean" | cliphist decode > "$tmp"
    mime=$(file --mime-type -b "$tmp" 2>/dev/null || echo "text/plain")
    wl-copy --type "$mime" < "$tmp"
    # Auto-paste for text items
    if echo "$mime" | grep -q 'text/'; then
        (sleep 0.1; wtype -M ctrl -k v -m ctrl) &
    fi
    rm -f "$tmp"
    notify-send -i clipboard "Clipboard" "Copied + auto-pasted" -t 1500
fi
