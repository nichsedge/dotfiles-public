#!/usr/bin/env bash
# Quick Tailscale toggle (On/Off) with desktop notification
set -euo pipefail

state=$(tailscale status --json 2>/dev/null | jq -r '.BackendState // "Stopped"')

if [ "$state" = "Running" ]; then
    if tailscale down; then
        notify-send -i network-vpn -a "Tailscale" "Tailscale Disconnected" "VPN tunnel turned off" -t 2000
    else
        notify-send -u critical -i network-vpn -a "Tailscale" "Failed to Disconnect" "Check tailscale status" -t 3000
    fi
else
    if tailscale up; then
        ip=$(tailscale ip -4 2>/dev/null | head -n1)
        notify-send -i network-vpn -a "Tailscale" "Tailscale Connected" "IPv4: ${ip:-active}" -t 2500
    else
        notify-send -u critical -i network-vpn -a "Tailscale" "Connect Failed" "Run 'tailscale login' in terminal" -t 3500
    fi
fi
