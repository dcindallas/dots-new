#!/usr/bin/env bash
# Volume icon-only module (pactl / PulseAudio or PipeWire-pulse)

ICON_MUTE="󰖁"
ICON_LOW=""
ICON_MED="󰖀"
ICON_HIGH="󰕾"

# --- helpers ---
have() { command -v "$1" >/dev/null 2>&1; }

default_sink() {
  # pactl (works with PulseAudio and PipeWire-pulse)
  pactl get-default-sink 2>/dev/null || pactl info 2>/dev/null | awk -F': ' '/Default Sink/{print $2}'
}

vol_pct() {
  local sink="${1:-@DEFAULT_SINK@}"
  # Take the highest channel percentage
  pactl get-sink-volume "$sink" 2>/dev/null | awk -F'/' '
    { for(i=0;i<=NF;i++) if ($i ~ /%/) { gsub(/[^0-9]/,"",$i); if($i>max) max=$i } }
    END { if (max=="") max=0; print max }'
}

is_muted() {
  local sink="${1:-@DEFAULT_SINK@}"
  pactl get-sink-mute "$sink" 2>/dev/null | awk '{print $2}'
}

print_icon() {
  local sink=$(default_sink)
  local mute=$(is_muted "$sink")
  if [[ "$mute" == "yes" ]]; then
    echo "$ICON_MUTE"
    return
  fi
  local p=$(vol_pct "$sink")
  if   (( p >= 67 )); then echo "$ICON_HIGH"
  elif (( p >= 34 )); then echo "$ICON_MED"
  elif (( p > 0  )); then echo "$ICON_LOW"
  else echo "$ICON_LOW"; fi
}

# --- actions for polybar clicks/scroll ---
case "$1" in
  --up)           pactl set-sink-volume @DEFAULT_SINK@ +5% ; exit ;;
  --down)         pactl set-sink-volume @DEFAULT_SINK@ -5% ; exit ;;
  --toggle-mute)  pactl set-sink-mute   @DEFAULT_SINK@ toggle ; exit ;;
  --once)         print_icon ; exit ;;
  --listen)
    print_icon
    # Update on sink/server changes
    pactl subscribe 2>/dev/null | awk '/(sink|server)/{print}' | while read -r _; do
      print_icon
    done
    exit ;;
esac

# default (one-shot)
print_icon
