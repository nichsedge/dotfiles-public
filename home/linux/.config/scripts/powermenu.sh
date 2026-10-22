#!/usr/bin/env bash
set -euo pipefail

# Fast, minimal fuzzel dmenu power menu
OPTIONS="󰌾 Lock\n󰤄 Suspend\n󰑐 Reboot\n󰐥 Power Off\n󰍃 Log Out"
CHOICE=$(printf "%b" "$OPTIONS" | fuzzel --dmenu --lines 5 --width 18 -p "Power: ")

case "$CHOICE" in
  *"Lock"*)
    hyprlock
    ;;
  *"Suspend"*)
    systemctl suspend
    ;;
  *"Reboot"*)
    systemctl reboot
    ;;
  *"Power Off"*)
    systemctl poweroff
    ;;
  *"Log Out"*)
    niri msg action quit --skip-confirmation
    ;;
esac
