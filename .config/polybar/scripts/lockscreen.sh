#!/bin/bash

# Function to simulate user activity by pressing the escape key
simulate_activity() {
    xdotool key Escape
}

# Function to lock the screen using betterlockscreen
lock_screen() {
    betterlockscreen -l dim
}

# Main loop to continuously monitor idle time
while true; do
    # Get idle time in seconds using xidle
    idle_time=$(xidle)

    # Check if idle time exceeds 1 hour (3600 seconds)
    if [ "$idle_time" -ge 480 ]; then
        # Simulate user activity (press Escape key) to reset idle timer
        simulate_activity

        # Lock the screen with betterlockscreen after simulating activity
        lock_screen
    fi

    # Sleep for a short interval before checking again
    sleep 60  # Check every 60 seconds (adjust as needed)
done
