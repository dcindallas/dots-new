#!/bin/bash

# File that displays the text
TEXT=$(~/.config/polybar/scripts/get_spotify_status.sh)

# Only scroll if text isn't empty
if [ -z "$TEXT" ]; then
    echo ""
    exit 0
fi

# Pad the text with spaces for a smoother scroll loop
SCROLL_TEXT="   $TEXT"
LENGTH=${#SCROLL_TEXT}
POSITION_FILE="/tmp/spotify_scroll_pos"
SPEED=0.1  # Adjust speed (in seconds)

# Initialize position if not set
if [ ! -f "$POSITION_FILE" ]; then
    echo 0 > "$POSITION_FILE"
fi

POSITION=$(cat "$POSITION_FILE")
POSITION=$(( (POSITION + 1) % LENGTH ))
echo "$POSITION" > "$POSITION_FILE"

# Create scrolling output
SCROLL_OUTPUT="${SCROLL_TEXT:$POSITION}${SCROLL_TEXT:0:$POSITION}"
echo "${SCROLL_OUTPUT:0:50}"  # Output first 50 chars (adjust for your Polybar width)
