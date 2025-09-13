#!/bin/bash

API_KEY="d9b47f3f48563b443d5c4504f09b9071"
CITY_ID="4710178"
UNITS="imperial"  # "imperial" for °F

weather=$(curl -sf "http://api.openweathermap.org/data/2.5/weather?id=$CITY_ID&units=$UNITS&appid=$API_KEY")

if [ -n "$weather" ]; then
  condition=$(echo "$weather" | jq -r ".weather[0].main")

  case "$condition" in
    "Clear")          icon="☀️" ;;     # Clear sky
    "Clouds")         icon="☁️" ;;     # Clouds
    "Rain"|"Drizzle") icon="🌧️" ;;    # Rain
    "Thunderstorm")   icon="⛈️" ;;    # Thunderstorm
    "Snow")           icon="🌨️" ;;    # Snow
    "Mist"|"Fog"|"Haze"|"Smoke") icon="🌫️" ;;  # Fog/haze/smoke
    "Dust"|"Sand"|"Ash") icon="🌫️" ;; # Dust/sand/ash
    "Squall")         icon="🌬️" ;;    # Wind
    "Tornado")        icon="🌪️" ;;    # Tornado
    *)                icon="❓" ;;     # Unknown
  esac

  echo "$icon"
else
  echo "N/A"
fi
