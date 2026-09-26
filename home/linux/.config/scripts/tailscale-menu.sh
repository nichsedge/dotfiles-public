#!/usr/bin/env bash
# Interactive Tailscale Wofi Menu for Hyprland & Niri
set -euo pipefail

if ! command -v tailscale >/dev/null 2>&1; then
    notify-send -u critical -i network-vpn -a "Tailscale" "Tailscale Not Found" "Tailscale CLI is not installed or not in PATH."
    exit 1
fi

backend_state=$(tailscale status --json 2>/dev/null | jq -r '.BackendState // "Stopped"')
my_ip=$(tailscale ip -4 2>/dev/null | head -n1 || true)

if [ "$backend_state" = "Running" ]; then
    prompt_text="Tailscale: 🟢 Connected ($my_ip)"
    menu_options="🔴 Disconnect Tailscale\n📋 Copy Tailscale IP ($my_ip)\n👥 Peers & Devices\n🩺 Run Netcheck Diagnostics\n🔄 Reconnect"
else
    prompt_text="Tailscale: 🔴 Disconnected"
    menu_options="🟢 Connect Tailscale\n🔑 Authenticate (tailscale login)\n🩺 Run Netcheck Diagnostics"
fi

chosen=$(printf "%b" "$menu_options" | wofi --dmenu --prompt "$prompt_text" --width 420 --height 280 --cache-file /dev/null)

[ -z "$chosen" ] && exit 0

case "$chosen" in
    *"Disconnect Tailscale"*)
        tailscale down
        notify-send -i network-vpn -a "Tailscale" "Tailscale Disconnected" "VPN tunnel turned off" -t 2000
        ;;
    *"Connect Tailscale"*)
        if tailscale up; then
            new_ip=$(tailscale ip -4 2>/dev/null | head -n1)
            notify-send -i network-vpn -a "Tailscale" "Tailscale Connected" "IPv4: ${new_ip:-active}" -t 2500
        else
            notify-send -u critical -i network-vpn -a "Tailscale" "Tailscale Connection Failed" "Run 'tailscale login' in terminal" -t 3500
        fi
        ;;
    *"Copy Tailscale IP"*)
        if [ -n "$my_ip" ]; then
            printf "%s" "$my_ip" | wl-copy
            notify-send -i network-vpn -a "Tailscale" "Copied to Clipboard" "$my_ip" -t 1500
        else
            notify-send -u low -i network-vpn -a "Tailscale" "No Tailscale IP" "Device is currently disconnected" -t 2000
        fi
        ;;
    *"Peers & Devices"*)
        peers=$(tailscale status 2>/dev/null || true)
        if [ -z "$peers" ]; then
            notify-send -i network-vpn -a "Tailscale" "No Peers" "No peer devices found on tailnet" -t 2000
            exit 0
        fi
        selected_peer=$(printf "%s" "$peers" | wofi --dmenu --prompt "Tailscale Peers" --width 650 --height 350 --cache-file /dev/null)
        [ -z "$selected_peer" ] && exit 0
        peer_ip=$(echo "$selected_peer" | awk '{print $1}')
        peer_name=$(echo "$selected_peer" | awk '{print $2}')
        peer_action=$(printf "📋 Copy IP (%s)\n📡 Ping Peer (%s)\n🌐 Open in Browser (http://%s)" "$peer_ip" "$peer_name" "$peer_ip" | wofi --dmenu --prompt "Action for $peer_name" --width 420 --height 220 --cache-file /dev/null)
        case "$peer_action" in
            *"Copy IP"*)
                printf "%s" "$peer_ip" | wl-copy
                notify-send -i network-vpn -a "Tailscale" "Copied to Clipboard" "$peer_ip ($peer_name)" -t 1500
                ;;
            *"Ping Peer"*)
                ghostty --title="Ping $peer_name" -e bash -c "ping -c 5 '$peer_ip'; echo; read -n 1 -s -r -p 'Press any key to close...'" &
                ;;
            *"Open in Browser"*)
                google-chrome-stable "http://$peer_ip" &
                ;;
        esac
        ;;
    *"Run Netcheck Diagnostics"*)
        ghostty --title="Tailscale Netcheck" -e bash -c "tailscale netcheck; echo; read -n 1 -s -r -p 'Press any key to close...'" &
        ;;
    *"Authenticate"*)
        ghostty --title="Tailscale Login" -e bash -c "tailscale login; echo; read -n 1 -s -r -p 'Press any key to close...'" &
        ;;
    *"Reconnect"*)
        tailscale down 2>/dev/null || true
        sleep 0.5
        tailscale up && notify-send -i network-vpn -a "Tailscale" "Tailscale Reconnected" "IPv4: $(tailscale ip -4 2>/dev/null | head -n1)" -t 2000
        ;;
esac
