#!/bin/bash
# SUPER+W to cycle wallpaper
WALL_DIR="$HOME/Pictures/Wallpapers"
WALL=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)
hyprctl hyprpaper preload "$WALL" >/dev/null 2>&1
hyprctl hyprpaper wallpaper ",$WALL" >/dev/null 2>&1
notify-send "Wallpaper" "$(basename "$WALL")"
