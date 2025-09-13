#!/bin/bash

ICON=""                         # Notification icon
SEP=$'\u00A0\u00A0'              # Double non-breaking space
MSG_FILE="/tmp/polybar_last_notification"
MAXLEN=80                        # Max characters shown
TIMEOUT=30                       # Seconds to keep message visible

# Get D-Bus session address from cache
address=$(cat ~/.cache/dbus-dunst.address 2>/dev/null)
[ -z "$address" ] && echo "${ICON}" && exit 0
export DBUS_SESSION_BUS_ADDRESS="$address"

# Pull latest message from dunst
msg=$(dunstctl history | jq -r '.data[0][0].summary.data')
[ -z "$msg" ] || [ "$msg" == "null" ] && msg=$(dunstctl history | jq -r '.data[0][0].body.data')

# Cache message + timestamp
if [ -n "$msg" ] && [ "$msg" != "null" ]; then
  echo "$(date +%s)|$msg" > "$MSG_FILE"
fi

# Read cached message
if [ -f "$MSG_FILE" ]; then
  IFS="|" read -r timestamp cached_msg < "$MSG_FILE"
  now=$(date +%s)
  age=$((now - timestamp))

  if [ "$age" -lt "$TIMEOUT" ]; then
    # Truncate if needed
    [[ ${#cached_msg} -gt $MAXLEN ]] && cached_msg="${cached_msg:0:$MAXLEN}…"

    # Strip leading/trailing quotes
    cached_msg="${cached_msg%\"}"
    cached_msg="${cached_msg#\"}"

    echo "${ICON}${SEP}${cached_msg}"
    exit 0
  fi
fi

# Timeout: show icon only
echo "${ICON}"
