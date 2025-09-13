#!/usr/bin/env bash
# Shows a single icon for the currently Playing MPRIS player.
# Players handled: Spotify, YouTube Music, Pandora (pithos/pandora), else a default note.
# Requires: playerctl, (optional) xrdb for color.

set -euo pipefail

have() { command -v "$1" >/dev/null 2>&1; }

get_playing_player() {
  # returns "<playerName>"
  playerctl -a status -f '{{playerName}} {{status}}' 2>/dev/null \
    | awk '$2=="Playing"{print $1; exit}'
}

is_youtube_music() {
  # For browser players, try to detect YTM from the media URL
  local p="$1"
  [[ "$p" =~ ^(google-chrome|chromium|brave|vivaldi|firefox)$ ]] || return 1
  local url
  url="$(playerctl -p "$p" metadata -f '{{xesam:url}}' 2>/dev/null || true)"
  [[ "$url" == *"music.youtube."* || "$url" == *"youtube.com/watch"* ]]
}

xrdb_color_base0A() {
  # Prefer base0A, fallback to color11, then a sane default
  local v
  v="$(xrdb -query 2>/dev/null | awk '$1=="base0A:"{print $2; exit}')"
  [[ -z "$v" ]] && v="$(xrdb -query 2>/dev/null | awk '$1=="*.base0A:"{print $2; exit}')"
  [[ -z "$v" ]] && v="$(xrdb -query 2>/dev/null | awk '$1=="color11:"{print $2; exit}')"
  echo "${v:-#8f9d6a}"
}

main() {
  have playerctl || { echo ""; exit 0; }

  local p icon
  p="$(get_playing_player || true)"
  [[ -z "$p" ]] && { echo ""; exit 0; }

  # Icon choices (Nerd Font / Font Awesome glyphs)
  # Spotify: \uf1bc     | YouTube: \uf167     | Pandora (brand often iffy) -> use music note
  # Default: \uf001  
  case "$p" in
    spotify)                    icon="" ;;  # FA brands Spotify
    youtube-music)              icon="" ;;  # FA brands YouTube
    pithos|pandora)             icon="♪" ;;  # Pandora via Pithos (no reliable brand in all fonts)
    google-chrome|chromium|brave|vivaldi|firefox)
                                 if is_youtube_music "$p"; then icon=""; else icon="♪"; fi ;;
    *)                           icon="♪" ;;
  esac

  # Optional: tint with base0A if xrdb is available
  if have xrdb; then
    color="$(xrdb_color_base0A)"
    printf '%%{F%s}%s%%{F-}\n' "$color" "$icon"
  else
    printf '%s\n' "$icon"
  fi
}

main

