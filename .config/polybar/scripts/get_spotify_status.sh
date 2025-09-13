#!/bin/bash

# Pick an active player: prefer Playing, else first Paused
pick_player() {
  # List all players with their status
  mapfile -t lines < <(playerctl -a status --format '{{playerName}} {{status}}' 2>/dev/null || true)
  [[ ${#lines[@]} -eq 0 ]] && return 1

  local p_playing=""
  local p_paused=""
  for line in "${lines[@]}"; do
    name="${line% *}"
    st="${line##* }"
    [[ "$st" == "Playing" ]] && { p_playing="$name"; break; }
    [[ -z "$p_paused" && "$st" == "Paused" ]] && p_paused="$name"
  done

  if [[ -n "$p_playing" ]]; then
    printf '%s' "$p_playing"
  elif [[ -n "$p_paused" ]]; then
    printf '%s' "$p_paused"
  else
    return 1
  fi
}

player=$(pick_player) || { echo ""; exit 0; }

status=$(playerctl -p "$player" status 2>/dev/null || echo "")
if [[ "$status" != "Playing" && "$status" != "Paused" ]]; then
  echo ""
  exit 0
fi

# Identity (friendly name) with fallback
identity=$(playerctl -p "$player" metadata --format '{{mpris:identity}}' 2>/dev/null | tr -d '\n')
[[ -z "$identity" ]] && identity=$(playerctl -p "$player" metadata --format '{{playerName}}' 2>/dev/null | tr -d '\n')

artist=$(playerctl -p "$player" metadata artist 2>/dev/null | tr -d '\n')
title=$(playerctl -p "$player" metadata title 2>/dev/null | tr -d '\n')

if [[ -n "$title" && -n "$artist" ]]; then
  echo "$title - $artist"
elif [[ -n "$title" ]]; then
  echo "[$identity] $title"
else
  echo "[$identity] No track info"
fi
