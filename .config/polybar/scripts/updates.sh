#!/usr/bin/env bash
set -euo pipefail

# --- SETTINGS ---
NOTIFY_ICON="${HOME}/.icons/dracula-icons-main/scalable/apps/system-upgrade.svg"
COUNT_MODE="${COUNT_MODE:-all}"         # all | repo | aur
SLEEP_HAS_UPDATES="${SLEEP_HAS_UPDATES:-10}"
SLEEP_NO_UPDATES="${SLEEP_NO_UPDATES:-1800}"

last_notified=-1

get_total_updates() {
  local count=0
  if command -v yay >/dev/null 2>&1; then
    case "$COUNT_MODE" in
      repo) count=$(yay -Qu --repo 2>/dev/null | wc -l) ;;  # pacman repos only
      aur)  count=$(yay -Qu --aur  2>/dev/null | wc -l) ;;  # AUR only
      *)    count=$(yay -Qu        2>/dev/null | wc -l) ;;  # repo + AUR (default)
    esac
  elif command -v checkupdates >/dev/null 2>&1; then
    # Fallback if yay missing
    count=$(checkupdates 2>/dev/null | wc -l || echo 0)
  else
    count=0
  fi
  printf '%d' "$count"
}

notify_if_needed() {
  local n="$1"
  command -v notify-send >/dev/null 2>&1 || return 0
  [[ "$n" -eq "$last_notified" ]] && return 0
  if   (( n > 50 )); then notify-send -u critical -i "$NOTIFY_ICON" "You really need to update!!" "$n new packages"
  elif (( n > 25 )); then notify-send -u normal   -i "$NOTIFY_ICON" "You should update soon"      "$n new packages"
  elif (( n > 2  )); then notify-send -u low      -i "$NOTIFY_ICON"                              "$n new packages"
  fi
  last_notified="$n"
}

while :; do
  updates=$(get_total_updates)
  notify_if_needed "$updates"

  if (( updates > 0 )); then
    echo "$updates update$([[ $updates -gt 1 ]] && echo s)"
    sleep "$SLEEP_HAS_UPDATES"
  else
    echo "rchLinux"
    sleep "$SLEEP_NO_UPDATES"
  fi
done
