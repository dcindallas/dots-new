#!/usr/bin/env bash
# Try a sensible GUI editor; fallback to terminal nmcli TUI

if command -v nm-connection-editor >/dev/null 2>&1; then
  nm-connection-editor &
elif command -v nmtui >/dev/null 2>&1; then
  alacritty -e nmtui & 2>/dev/null || kitty nmtui &
else
  notify-send "Wi-Fi" "No GUI found. Install network-manager-applet or use your Rofi menu."
fi
