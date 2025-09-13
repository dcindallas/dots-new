#!/usr/bin/env bash
set -euo pipefail

# prevent duplicates
pkill -x xidlehook 2>/dev/null || true

START="$HOME/.local/bin/start-ascii-saver"
STOP="$HOME/.local/bin/stop-ascii-saver"
LOCK="$HOME/.local/bin/lock-with-saver"

exec xidlehook --detect-sleep \
  --timer 120 "$START" "$STOP" \
  --timer 1440 "$LOCK" '' \
  --timer 1560 'xset dpms force off' 'xset dpms force on' \
  --timer 1800 'systemctl suspend' ''
