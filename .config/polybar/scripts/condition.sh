#!/bin/bash

API_KEY="d9b47f3f48563b443d5c4504f09b9071"
CITY_ID="4710178"
UNITS="metric"  # Use "imperial" for Fahrenheit

weather=$(curl -sf "http://api.openweathermap.org/data/2.5/weather?id=$CITY_ID&units=$UNITS&appid=$API_KEY")

if [ ! -z "$weather" ]; then
    condition=$(echo "$weather" | jq -r ".weather[0].main")
    
    # Assign icons based on condition
    case "$condition" in
        "Clear") icon="" ;;    # Sunny icon
        "Clouds") icon="" ;;   # Cloudy icon
        "Rain") icon="" ;;     # Rainy icon
        "Drizzle") icon="" ;;  # Drizzle icon
        "Thunderstorm") icon="" ;; # Thunderstorm icon
        "Snow") icon="" ;;     # Snowy icon
        "Mist" | "Fog") icon="" ;; # Foggy icon
        *) icon="" ;;          # Default icon for unknown conditions
    esac
    
    echo "$icon"
else
    echo "N/A"
fi
