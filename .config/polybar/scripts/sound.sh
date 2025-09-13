#!/usr/bin/env bash
# Polybar volume helper for PipeWire (wpctl)
# Usage: polybar-volume [up|down|toggle|listen]

SINK="@DEFAULT_AUDIO_SINK@"   # change if you want a specific sink
STEP="5%"

get() {
  local out
  out="$(wpctl get-volume "$SINK" 2>/dev/null || true)"         # e.g. "Volume: 0.53 [MUTED]"
  [[ -z "$out" ]] && echo " --" && return 0
  local vol mute
  vol=$(printf "%s" "$out" | awk '{for(i=1;i<=NF;i++) if ($i ~ /^[0-9.]+$/){print $i; exit}}')
  mute=$(printf "%s" "$out" | grep -q "\[MUTED\]" && echo yes || echo no)
  # to percent (round)
  local pct
  pct=$(awk -v v="$vol" 'BEGIN{printf("%.0f", v*100)}')
  # icon
  local icon=""
  (( pct == 0 )) && icon=""
  (( pct >= 60 )) && icon=""
  [[ "$mute" == "yes" ]] && icon=""
  if [[ "$mute" == "yes" ]]; then
    printf "%s  MUTED\n" "$icon"
  else
    printf "%s  %s%%\n" "$icon" "$pct"
  fi
}

case "${1:-show}" in
  up)     wpctl set-volume "$SINK" "${STEP}+" ;;
  down)   wpctl set-volume "$SINK" "${STEP}-" ;;
  toggle) wpctl set-mute   "$SINK" toggle     ;;
  listen)
    # live updates via PulseAudio-compat events (works under PipeWire)
    pactl subscribe | grep --line-buffered "sink" | while read -r _; do get; done
    ;;
  show|*) get ;;
esac
