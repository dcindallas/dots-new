#!/usr/bin/env bash

playerctlstatus=$(playerctl status 2> /dev/null)

if [[ -z "$playerctlstatus" ]]; then
    echo ""  # No media player detected
elif [[ "$playerctlstatus" == "Playing" ]]; then
    # Show green pause icon
    echo "%{A1:playerctl pause:}%{F#cf6a4c}󰏤%{F-}%{A}"
else
    # Show red play icon
    echo "%{A1:playerctl play:}%{F#8f9d6a}%{F-}%{A}"
fi
