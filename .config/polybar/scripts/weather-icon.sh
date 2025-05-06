#!/bin/bash

# Fetch the weather condition
condition=$(curl -s 'wttr.in/MCKINNEY?format=%C')

# Define icons for different weather conditions using Hack Nerd Font
case "$condition" in
    *"Sunny"*) icon="" ;;        # Clear/Sunny icon
    *"Clear"*) icon="" ;;        # Clear/Night icon
    *"Cloudy"*) icon="" ;;       # Cloudy icon
    *"Partly cloudy"*) icon="" ;;# Partly cloudy icon
    *"Overcast"*) icon="" ;;     # Overcast icon
    *"Rain"*) icon="" ;;         # Rainy icon
    *"Snow"*) icon="" ;;         # Snowy icon
    *"Fog"*) icon="" ;;          # Foggy icon
    *"Thunder"*) icon="" ;;      # Thunderstorm icon (lightning bolt)
    *"Mist"*) icon="" ;;         # Mist icon
    *) icon="" ;;                # Default icon if condition is unrecognized
esac

# Output the icon wrapped with the font index for Hack Nerd Font (e.g., font-2 for Hack Nerd Font)
echo "$icon"
