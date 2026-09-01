#!/usr/bin/env bash
# macOS-like Quick Session / Power Menu
chosen=$(printf "🔒 Lock Screen (⌘L)\n⏾ Sleep / Suspend\n🚪 Log Out (⌘⇧Q)\n🔄 Restart System\n🛑 Shut Down" | wofi --dmenu --prompt " System Menu" --width 350 --height 280)

case "$chosen" in
    *"Lock Screen"*)
        pidof hyprlock || hyprlock
        ;;
    *"Sleep"*)
        systemctl suspend
        ;;
    *"Log Out"*)
        hyprctl dispatch exit 0
        ;;
    *"Restart System"*)
        systemctl reboot
        ;;
    *"Shut Down"*)
        systemctl poweroff
        ;;
esac
