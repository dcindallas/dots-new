#!/bin/bash

# Delay before flip clock kicks in (e.g., 2 min)
sleep 120

# Start Gluqlo as background process
gluqlo -root &
FLIP_PID=$!

# Show flip clock for 1 hour
sleep 3600

# Kill Gluqlo
kill $FLIP_PID
sleep 1

# Lock and blank screen
betterlockscreen -l
xset dpms force off
