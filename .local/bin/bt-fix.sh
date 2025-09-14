#!/usr/bin/env bash
set -euo pipefail

# find first available bluetooth sink
SINK=$(pactl list short sinks | awk '/bluez_output/ {print $2; exit}')

if [ -n "$SINK" ]; then
  echo "Switching default sink to: $SINK"
  pactl set-default-sink "$SINK"
  # play a short sound to wake it up
  paplay /usr/share/sounds/alsa/Front_Center.wav --device="$SINK" || true
else
  echo "No Bluetooth sink found!"
  exit 1
fi
